DECLARE @dbName nvarchar(30);
SET @dbName = 'AdventureWorksDW2016'

/* Backup the database */
BACKUP DATABASE @dbName TO DISK = 'C:\Temp\bu.bak'

/* Save collation information from columns to temp table */
SELECT ao.name as 'Object name', ao.type, ao.type_desc, C.object_id, c.name as 'Column name', c.max_length,  c.collation_name
INTO TEMP_COLLATION_INFO_BEFORE_CHANGE
FROM sys.objects T
INNER JOIN sys.columns C
ON T.object_id = C.object_id
INNER JOIN sys.all_objects ao
ON T.object_id  = ao.object_id
WHERE T.type in ('U','V') 
order by ao.name

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

select * From TEMP_COUNTS_BEFORE_COLLATION

/* Checks after drops */
select count(distinct object_id) from sys.indexes
select count(distinct object_id) from sys.key_constraints
select count(distinct object_id) from sys.foreign_keys