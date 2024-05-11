
/*
در صورت امکان GUID عدم استفاده از
*/
--ایجاد بانک اطلاعاتی تستی
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO
--------------------------------------------------------------------
/*
ایجاد جدول اول به صورت یکتا با یک فیلد عدد
*/
USE  MyDB2017
GO
DROP TABLE IF EXISTS TestTable_INT
GO
CREATE TABLE TestTable_INT 
(
	col1 int NOT NULL PRIMARY KEY ,
	col2 int NULL,
	col3 int NULL,
	col4 varchar(50) NULL
)
GO
DROP TABLE IF EXISTS TestTable_GUID
GO
CREATE TABLE TestTable_GUID 
(
	col1 uniqueidentifier NOT NULL PRIMARY KEY ,
    col2 int NULL,
    col3 int NULL,
    col4 varchar(50) NULL
)
GO
SET NOCOUNT ON
--درج تعدادی رکورد تستی در جدول
DECLARE @val INT
SELECT @val=1
WHILE @val < 5000000
BEGIN  
   INSERT INTO TestTable_INT (col1, col2,  col3, col4) 
     VALUES (@val,round(rand()*100000,0),round(rand()*100000,0),'TEST' + CAST(@val AS VARCHAR))

   INSERT INTO TestTable_GUID (col1, col2,  col3, col4) 
     VALUES (newid(),round(rand()*100000,0),round(rand()*100000,0),'TEST' + CAST(@val AS VARCHAR))

   SELECT @val=@val+1
END
GO 
--------------------------------------------------------------------
--بررسی حجم جدول
SP_SPACEUSED TestTable_INT
GO
SP_SPACEUSED TestTable_GUID
GO
SELECT
	OBJECT_NAME(i.object_id) AS TableName,
	i.name AS IndexName,
	SUM(s.used_page_count) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE 
	OBJECT_NAME(i.object_id) like '%testtable%'
GROUP BY 
	i.name,i.object_id
GO
