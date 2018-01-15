# Created by Mika Haapsaari / ald4ri 2017
# https://github.com/ald4ri/
# Sometimes you will create a SQL Server instance or database and you don't really know what kind of collation you will need for it.
# Unfortunately, changing collations after you have created your instance and databases is not as trivial of a task as it should be. 
# Fear no more, with this simple collection of scripts you can change the collation of your instance, DB and table collation easily.

This collection includes the following files, and is also the executing order of the scripts:
001_Preparations.sql
002_ChangeInstanceCollation.txt
01_ChangeDBCollation.sql
02_PROC_GetColumnObjects.sql
03_PROC_DropColumnObjects.sql
04_DropAndCreate.sql
05_ChangeTableCollation.sql