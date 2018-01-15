/* Save these results to file and execute  */ 

/* Drop Keys and Indexes */
DECLARE @TableName nvarchar(255)
DECLARE MyTableCursor Cursor
FOR 
SELECT name FROM sys.tables WHERE [type] = 'U' and name <> 'sysdiagrams' ORDER BY name 
OPEN MyTableCursor

FETCH NEXT FROM MyTableCursor INTO @TableName
WHILE @@FETCH_STATUS = 0
    BEGIN
     EXEC ScriptDropTableKeys @TableName

    FETCH NEXT FROM MyTableCursor INTO @TableName
END
CLOSE MyTableCursor
DEALLOCATE MyTableCursor

/* Create keys and indexes */

DECLARE @TableName nvarchar(255)
DECLARE MyTableCursor Cursor
FOR 
SELECT name FROM sys.tables WHERE [type] = 'U' and name <> 'sysdiagrams' ORDER BY name 
OPEN MyTableCursor

FETCH NEXT FROM MyTableCursor INTO @TableName
WHILE @@FETCH_STATUS = 0
    BEGIN
    EXEC ScriptCreateTableKeys @TableName

    FETCH NEXT FROM MyTableCursor INTO @TableName
END
CLOSE MyTableCursor
DEALLOCATE MyTableCursor
