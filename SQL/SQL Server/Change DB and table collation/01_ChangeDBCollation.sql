/*CHECK*/
SELECT name, collation_name FROM sys.databases;  

/*SET*/
ALTER DATABASE AdventureWorksDW2016
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

GO

ALTER DATABASE AdventureWorksDW2016
COLLATE Finnish_Swedish_CI_AS;

ALTER DATABASE AdventureWorksDW2016
SET MULTI_USER;

GO

/*Verify
Note: This returns NULL for some reason, although change has been made*/
SELECT name, collation_name FROM sys.databases;  
