CREATE PROC [dbo].[ScriptDropTableKeys]
    @table_name SYSNAME
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @crlf CHAR(2)
    SET @crlf = CHAR(13) + CHAR(10)
    DECLARE @object_id INT
    SET @object_id = OBJECT_ID(@table_name)
    DECLARE @sql NVARCHAR(MAX)

    SELECT
        'ALTER TABLE ' + 
            QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + 
            QUOTENAME(OBJECT_NAME(parent_object_id)) + @crlf +
        'DROP CONSTRAINT ' + QUOTENAME(name) + ';' + 
            @crlf + @crlf COLLATE database_default AS [-- Drop Referencing FKs]
    FROM sys.foreign_keys
    WHERE
        referenced_object_id = @object_id
        AND is_disabled = 0
    ORDER BY
        key_index_id DESC

    SET @sql = '' +
        'SELECT ' +
            'statement AS [-- Drop Candidate Keys] ' +
        'FROM ' +
        '( ' +
            'SELECT ' +
                'CASE ' +
                    'WHEN 1 IN (i.is_unique_constraint, i.is_primary_key) THEN ' +
                        '''ALTER TABLE '' + ' +
                            'QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + ''.'' + ' +
                            'QUOTENAME(OBJECT_NAME(i.object_id)) + @crlf + ' +
                        '''DROP CONSTRAINT '' + QUOTENAME(i.name) + '';'' + ' +
                            '@crlf + @crlf COLLATE database_default ' +
                    'ELSE ' +
                        '''DROP INDEX '' + QUOTENAME(i.name) + @crlf + ' +
                        '''ON '' + ' +
                            'QUOTENAME(OBJECT_SCHEMA_NAME(object_id)) + ''.'' + ' +
                            'QUOTENAME(OBJECT_NAME(object_id)) + '';'' + ' +
                                '@crlf + @crlf COLLATE database_default ' +
                'END AS statement, ' +
                'i.index_id ' +
            'FROM sys.indexes AS i ' +
            'WHERE ' +
                'i.object_id = @object_id ' +
                'AND i.is_unique = 1 ' +
                --filtered and hypothetical indexes cannot be candidate keys
                'AND i.is_hypothetical = 0 ' +
                'AND i.is_disabled = 0 ' +
        ') AS x ' +
        'ORDER BY ' +
            'index_id DESC '

    EXEC sp_executesql 
@sql,
        N'@object_id INT, @crlf CHAR(2)',
        @object_id, @crlf

END
