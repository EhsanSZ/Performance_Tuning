
/*
کم حجم بودن کلاستر ایندکس
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
ایجاد جداول
*/
USE  MyDB2017
GO
DROP TABLE IF EXISTS TestTable_SingleKey
GO
CREATE TABLE TestTable_SingleKey 
(
	col1 int NOT NULL ,
	col2 DATE NULL,
	col3 int NULL,
	col4 varchar(50) NULL
)
GO
DROP TABLE IF EXISTS TestTable_MultipleKey
GO
CREATE TABLE TestTable_MultipleKey 
(
	col1 int NOT NULL ,
    col2 DATE NOT NULL,
    col3 int NULL,
    col4 varchar(50) NULL
)
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered_SingleKey ON TestTable_SingleKey(col1)
CREATE UNIQUE CLUSTERED INDEX IX_Clustered_MultipleKey ON TestTable_MultipleKey(col2,col1)
GO
--درج تعدادی رکورد تستی در جدول
SET NOCOUNT ON
DECLARE @val INT
SELECT @val=1
WHILE @val < 5000000
BEGIN  
   INSERT INTO TestTable_SingleKey (col1, col2,  col3, col4) 
     VALUES (@val,GETDATE(),round(rand()*100000,0),'TEST' + CAST(@val AS VARCHAR))

   INSERT INTO TestTable_MultipleKey (col1, col2,  col3, col4) 
     VALUES (@val,GETDATE(),round(rand()*100000,0),'TEST' + CAST(@val AS VARCHAR))

   SELECT @val=@val+1
END
GO 
--------------------------------------------------------------------
USE MyDB2017
GO
--بررسی حجم جدول
SP_SPACEUSED TestTable_SingleKey
GO
SP_SPACEUSED TestTable_MultipleKey
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
--------------------------------------------------------------------
/*
Hotspot 
*/
USE MyDB2017
GO
DROP TABLE IF EXISTS Students1
DROP TABLE IF EXISTS Students2
GO
CREATE TABLE Students1
(
	StudentID INT IDENTITY,
	InsertDate DATETIME,
	FirstName CHAR(2000),
	LastName CHAR(2000)
)
GO
CREATE TABLE Students2
(
	StudentID INT IDENTITY,
	InsertDate DATETIME,
	FirstName CHAR(2000),
	LastName CHAR(2000)
)
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON Students1(StudentID)
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON Students2(InsertDate,StudentID)
GO
--SQLQueryStress
INSERT INTO Students1 (InsertDate,FirstName,LastName) VALUES (GETDATE(),'A','B')
INSERT INTO Students2 (InsertDate,FirstName,LastName) VALUES (GETDATE(),'A','B')

--حجم
SELECT
	OBJECT_NAME(i.object_id) AS TableName,
	i.name AS IndexName,
	SUM(s.used_page_count) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE 
	OBJECT_NAME(i.object_id) like '%Students%'
GROUP BY 
	i.name,i.object_id
GO
--آنالیز ایندکس جدول 
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count,fragment_count,avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('Students1'),
	1,
	NULL,
	'DETAILED'
)
GO
--آنالیز ایندکس جدول 
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count,fragment_count,avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('Students2'),
	1,
	NULL,
	'DETAILED'
)
GO