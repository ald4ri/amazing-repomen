/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [AdventureWorksDW2016]
GO
/****** Object:  StoredProcedure [dbo].[ScriptCreateTableKeys]    Script Date: 16.11.2017 10.30.16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Script Table Keys
(C) 2010 Adam Machanic - amachanic@gmail.com
Modified by Mika Haapsaari
http://sqlblog.com/blogs/adam_machanic/archive/2010/04/04/
       rejuvinated-script-creates-and-drops-for-candidate-keys
       -and-referencing-foreign-keys.aspx
This script produces a script of all of the candidate keys (primary keys or unique 
constraints) as well as referencing foreign keys, for the target table. To use, put
SSMS into "results in text" mode and run the script. The output will be a formatted
script that you can cut and paste to use elsewhere.

Don't forget to configure the maximum text size before using. The default is 256
characters--not enough for many cases.

Tools->Options->Query Results->Results to Text->Maximum number of characters->8192
*/


CREATE PROC [dbo].[ScriptCreateTableKeys]
    @table_name SYSNAME
AS
BEGIN
    SET NOCOUNT ON

    --Note: Disabled keys and constraints are ignored
    --TODO: Drop and re-create referencing XML indexes, FTS catalogs

    DECLARE @crlf CHAR(2)
    SET @crlf = CHAR(13) + CHAR(10)
    DECLARE @version CHAR(4)
    SET @version = SUBSTRING(@@VERSION, LEN('Microsoft SQL Server') + 2, 4)
    DECLARE @object_id INT
    SET @object_id = OBJECT_ID(@table_name)
    DECLARE @sql NVARCHAR(MAX)

    SET @sql = '' +
        'SELECT ' +
            'CASE ' +
                'WHEN 1 IN (i.is_primary_key, i.is_unique_constraint) THEN ' +
                    '''ALTER TABLE '' + ' +
                        'QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + ''.'' + ' +
                        'QUOTENAME(OBJECT_NAME(i.object_id)) + @crlf + ' +
                    '''ADD '' + ' +
                        'CASE k.is_system_named ' +
                            'WHEN 0 THEN ''CONSTRAINT '' + QUOTENAME(k.name) + @crlf ' +
                            'ELSE '''' ' +
                        'END + ' +
                    'CASE k.type ' +
                        'WHEN ''UQ'' THEN ''UNIQUE'' ' +
                        'ELSE ''PRIMARY KEY'' ' +
                    'END + '' '' + ' +
                    'i.type_desc  + @crlf + ' +
                    'kc.key_columns + @crlf ' +
                'ELSE ' +
                    '''CREATE UNIQUE '' + i.type_desc + '' INDEX '' + ' +
                        'QUOTENAME(i.name) + @crlf + ' +
                    '''ON '' + ' +
                        'QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + ''.'' + ' +
                        'QUOTENAME(OBJECT_NAME(i.object_id)) + @crlf + ' +
                    'kc.key_columns + @crlf + ' +
                    'COALESCE ' +
                    '( ' +
                        '''INCLUDE '' + @crlf + ' +
                        '''( '' + @crlf + ' +
                            'STUFF ' +
                            '( ' +
                                '( ' +
                                    'SELECT ' +
                                    '( ' +
                                        'SELECT ' +
                                            ''','' + @crlf + '' '' + QUOTENAME(c.name) AS [text()] ' +
                                        'FROM sys.index_columns AS ic ' +
                                        'JOIN sys.columns AS c ON ' +
                                            'c.object_id = ic.object_id ' +
                                            'AND c.column_id = ic.column_id ' +
                                        'WHERE ' +
                                            'ic.object_id = i.object_id ' +
                                            'AND ic.index_id = i.index_id ' +
                                            'AND ic.is_included_column = 1 ' +
                                        'ORDER BY ' +
                                            'ic.key_ordinal ' +
                                        'FOR XML PATH(''''), TYPE ' +
                                    ').value(''.'', ''VARCHAR(MAX)'') ' +
                                '), ' +
                                '1, ' +
                                '3, ' +
                                ''''' ' +
                            ') + @crlf + ' +
                        ''')'' + @crlf, ' +
                        ''''' ' +
                    ') ' +
            'END + ' +
            '''WITH '' + @crlf + ' +
            '''('' + @crlf + ' +
                ''' PAD_INDEX = '' + ' +
                        'CASE CONVERT(VARCHAR, i.is_padded) ' +
                            'WHEN 1 THEN ''ON'' ' +
                            'ELSE ''OFF'' ' +
                        'END + '','' + @crlf + ' +
                'CASE i.fill_factor ' +
                    'WHEN 0 THEN '''' ' +
                    'ELSE ' +
                        ''' FILLFACTOR = '' + ' +
                                'CONVERT(VARCHAR, i.fill_factor) + '','' + @crlf ' +
                'END + ' +
                ''' IGNORE_DUP_KEY = '' + ' +
                        'CASE CONVERT(VARCHAR, i.ignore_dup_key) ' +
                            'WHEN 1 THEN ''ON'' ' +
                            'ELSE ''OFF'' ' +
                        'END + '','' + @crlf + ' +
                ''' ALLOW_ROW_LOCKS = '' + ' +
                        'CASE CONVERT(VARCHAR, i.allow_row_locks) ' +
                            'WHEN 1 THEN ''ON'' ' +
                            'ELSE ''OFF'' ' +
                        'END + '','' + @crlf + ' +
                ''' ALLOW_PAGE_LOCKS = '' + ' +
                        'CASE CONVERT(VARCHAR, i.allow_page_locks) ' +
                            'WHEN 1 THEN ''ON'' ' +
                            'ELSE ''OFF'' ' +
                        'END + ' +
         '@crlf + ' +
            ''') '' + @crlf + ' +
            '''ON '' + ds.data_space + '';'' + ' +
                '@crlf + @crlf COLLATE database_default AS [-- Create Candidate Keys] ' +
        'FROM sys.indexes AS i ' +
        'LEFT OUTER JOIN sys.key_constraints AS k ON ' +
            'k.parent_object_id = i.object_id ' +
            'AND k.unique_index_id = i.index_id ' +
        'CROSS APPLY ' +
        '( ' +
            'SELECT ' +
                '''( '' + @crlf + ' +
                    'STUFF ' +
                    '( ' +
                        '( ' +
                            'SELECT ' +
                            '( ' +
                                'SELECT ' +
                                    ''','' + @crlf + '' '' + QUOTENAME(c.name) AS [text()] ' +
                                'FROM sys.index_columns AS ic ' +
                                'JOIN sys.columns AS c ON ' +
                                    'c.object_id = ic.object_id ' +
                                    'AND c.column_id = ic.column_id ' +
                                'WHERE ' +
                                    'ic.object_id = i.object_id ' +
                                    'AND ic.index_id = i.index_id ' +
                                    'AND ic.key_ordinal > 0 ' +
                                'ORDER BY ' +
                                    'ic.key_ordinal ' +
                                'FOR XML PATH(''''), TYPE ' +
                            ').value(''.'', ''VARCHAR(MAX)'') ' +
                        '), ' +
                        '1, ' +
                        '3, ' +
                        ''''' ' +
                    ') + @crlf + ' +
                ''')'' ' +
        ') AS kc (key_columns) ' +
        'CROSS APPLY ' +
        '( ' +
            'SELECT ' +
                'QUOTENAME(d.name) + ' +
                    'CASE d.type ' +
                        'WHEN ''PS'' THEN ' +
                            '+ ' +
                            '''('' + ' +
                                '( ' +
                                    'SELECT ' +
                                        'QUOTENAME(c.name) ' +
                                    'FROM sys.index_columns AS ic ' +
                                    'JOIN sys.columns AS c ON ' +
                                        'c.object_id = ic.object_id ' +
                                        'AND c.column_id = ic.column_id ' +
                                    'WHERE ' +
                                        'ic.object_id = i.object_id ' +
                                        'AND ic.index_id = i.index_id ' +
                                        'AND ic.partition_ordinal = 1 ' +
                                ') + ' +
                            ''')'' ' +
                        'ELSE '''' ' +
                    'END ' +
            'FROM sys.data_spaces AS d ' +
            'WHERE ' +
                'd.data_space_id = i.data_space_id ' +
        ') AS ds (data_space) ' +
        'WHERE ' +
            'i.object_id = @object_id ' +
            'AND i.is_unique = 1 ' +
            'AND i.is_hypothetical = 0 ' +
            'AND i.is_disabled = 0 ' +
        'ORDER BY ' +
            'i.index_id '

    EXEC sp_executesql
@sql,
        N'@object_id INT, @crlf CHAR(2)',
        @object_id, @crlf

    SELECT
        'ALTER TABLE ' + 
            QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id)) + '.' + 
            QUOTENAME(OBJECT_NAME(fk.parent_object_id)) + @crlf +
        CASE fk.is_not_trusted
            WHEN 0 THEN 'WITH CHECK '
            ELSE 'WITH NOCHECK '
        END + 
            'ADD ' +
                CASE fk.is_system_named
                    WHEN 0 THEN 'CONSTRAINT ' + QUOTENAME(name) + @crlf
                    ELSE ''
                END +
        'FOREIGN KEY ' + @crlf + 
        '( ' + @crlf + 
            STUFF
(
(
                    SELECT
(
                        SELECT 
                            ',' + @crlf + ' ' + QUOTENAME(c.name) AS [text()]
                        FROM sys.foreign_key_columns AS fc
                        JOIN sys.columns AS c ON
                            c.object_id = fc.parent_object_id
                            AND c.column_id = fc.parent_column_id
                        WHERE 
                            fc.constraint_object_id = fk.object_id
                        ORDER BY
                            fc.constraint_column_id
                        FOR XML PATH(''), TYPE
                    ).value('.', 'VARCHAR(MAX)')
                ),
                1,
                3,
                ''
            ) + @crlf + 
        ') ' +
        'REFERENCES ' + 
            QUOTENAME(OBJECT_SCHEMA_NAME(fk.referenced_object_id)) + '.' + 
            QUOTENAME(OBJECT_NAME(fk.referenced_object_id)) + @crlf +
        '( ' + @crlf + 
            STUFF
(
(
                    SELECT
(
                        SELECT 
                            ',' + @crlf + ' ' + QUOTENAME(c.name) AS [text()]
                        FROM sys.foreign_key_columns AS fc
                        JOIN sys.columns AS c ON
                            c.object_id = fc.referenced_object_id
                            AND c.column_id = fc.referenced_column_id
                        WHERE 
                            fc.constraint_object_id = fk.object_id
                        ORDER BY
                            fc.constraint_column_id
                        FOR XML PATH(''), TYPE
                    ).value('.', 'VARCHAR(MAX)')
                ),
                1,
                3,
                ''
            ) + @crlf + 
        ');' + 
            @crlf + @crlf COLLATE database_default AS [-- Create Referencing FKs]
    FROM sys.foreign_keys AS fk
    WHERE
        referenced_object_id = @object_id
        AND is_disabled = 0
    ORDER BY
        key_index_id

END
