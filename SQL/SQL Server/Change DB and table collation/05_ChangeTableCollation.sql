/* NOTE: You have to change view collations by hand! 

Example ALTER:

	ALTER VIEW dbo.vAssocSeqLineItems
	AS SELECT 'OrderNumber' COLLATE Finnish_Swedish_BIN2 AS 'OrderNumber', 
	'LineNumber' COLLATE Finnish_Swedish_BIN2 AS 'Linenumber',
    'Model' COLLATE Finnish_Swedish_BIN2 AS 'Model'
	FROM dbo.vDMPrep
	WHERE (FiscalYear = '2013')

*/


DECLARE @TableName nvarchar(255), 
		@ColumnName nvarchar(255), 
		@DataType nvarchar(255), 
		@CollationName nvarchar(255) = 'Finnish_Swedish_BIN2', 
		@CharacterMaxLen nvarchar(255),
		@IsNullable nvarchar(255),
		@SQLText nvarchar(2000)

DECLARE MyTableCursor Cursor
	FOR 
		SELECT name FROM sys.tables WHERE [type] = 'U' and name <> 'sysdiagrams' ORDER BY name 
OPEN MyTableCursor

	FETCH NEXT FROM MyTableCursor INTO @TableName
		WHILE @@FETCH_STATUS = 0
	BEGIN
	DECLARE MyColumnCursor Cursor
		FOR 
	SELECT	COLUMN_NAME,
			DATA_TYPE, 
			CHARACTER_MAXIMUM_LENGTH,
			IS_NULLABLE 
	from INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = @TableName 
			AND (Data_Type LIKE '%char%' OR Data_Type LIKE '%text%') 
			AND COLLATION_NAME <> @CollationName
			ORDER BY ordinal_position 
			Open MyColumnCursor

	FETCH NEXT FROM MyColumnCursor INTO @ColumnName, @DataType, @CharacterMaxLen, @IsNullable
		WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @SQLText = 'ALTER TABLE ' + @TableName + ' ALTER COLUMN [' + @ColumnName + '] ' + @DataType + '(' + 
		CASE WHEN @CharacterMaxLen = -1 
		THEN 'MAX' 
		ELSE @CharacterMaxLen END + 
		') COLLATE ' + @CollationName + ' ' + 
		CASE WHEN @IsNullable = 'NO' 
		THEN 'NOT NULL' 
		ELSE 'NULL' END
	PRINT @SQLText 

	FETCH NEXT FROM MyColumnCursor INTO @ColumnName, @DataType, @CharacterMaxLen, @IsNullable
	END
	
	CLOSE MyColumnCursor
	DEALLOCATE MyColumnCursor

	FETCH NEXT FROM MyTableCursor INTO @TableName
	END
	CLOSE MyTableCursor
	DEALLOCATE MyTableCursor






