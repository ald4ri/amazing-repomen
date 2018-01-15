/**
Script by Mika Haapsaari 2017
https://github.com/ald4ri

Run in script in preparation of the collation changes. Takes backups of the whole database

@dbName						Set the database name you want to change your collation to
@backupDestination			Set the destination of your database backup

*/

DECLARE @dbName nvarchar(30);
DECLARE @backupDestination nvarchar(max);

SET @dbName = 'AdventureWorksDW2016'
SET @backupDestination = 'C:\Temp\bu.bak'

/* Backup the database */
BACKUP DATABASE @dbName TO DISK = @backupDestination

/* Save collation information from columns to temp table */
SELECT	ao.name as 'Object name', 
		ao.type, 
		ao.type_desc, 
		C.object_id, 
		C.name as 'Column name', 
		C.max_length,  
		C.collation_name
INTO TEMP_COLLATION_INFO_BEFORE_CHANGE
FROM sys.objects T
		INNER JOIN sys.columns C
			ON T.object_id = C.object_id
		INNER JOIN sys.all_objects ao
			ON T.object_id  = ao.object_id
WHERE T.type in ('U','V') 
ORDER BY ao.name

/* Add counts of objects to temp table */

CREATE TABLE [dbo].[TEMP_COUNTS_BEFORE_COLLATION](
	[OBJECT_TYPE] VARCHAR(50),
	[COUNT] INT
)

-- Indexes
INSERT INTO dbo.TEMP_COUNTS_BEFORE_COLLATION
	SELECT 'Indexes', count(distinct object_id) 
	FROM sys.indexes

-- Key constraints
INSERT INTO dbo.TEMP_COUNTS_BEFORE_COLLATION
	SELECT 'Key constraints', count(distinct object_id) 
	FROM sys.key_constraints

-- Foreign keys
INSERT INTO dbo.TEMP_COUNTS_BEFORE_COLLATION
	SELECT 'Foreign keys', count(distinct object_id) 
	FROM sys.foreign_keys


/* 
* After you run add the database objects back to the database, you can check check that the results here match each other:
select * form TEMP_COUNTS_BEFORE_COLLATION
select count(distinct object_id) from sys.indexes
select count(distinct object_id) from sys.key_constraints
select count(distinct object_id) from sys.foreign_keys
*/