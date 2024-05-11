
/*
بررسی تاثیر یکتا بودن کلاستر ایندکس 
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
ایجاد جدول اول و درج دیتای تستی در آن
است Unique Clustered Index در حالت اول جدول دارای یک 
امکان درج مقدار تکراری به ازای کلید وجود ندارد
*/
USE MyDB2017
GO
DROP TABLE IF EXISTS Customers1
GO
CREATE TABLE Customers1
(
   CustomerID INT NOT NULL IDENTITY(1, 1) PRIMARY KEY ,
   CustomerName CHAR(100) NOT NULL,
   CustomerAddress CHAR(100) NOT NULL,
   Comments CHAR(189) NOT NULL
)
GO
--درج 80000 رکورد در جدول
SET NOCOUNT ON
DECLARE @i INT = 1
WHILE (@i <= 80000)
BEGIN
   INSERT INTO Customers1 VALUES
   (
      'CustomerName' + CAST(@i AS CHAR),
      'CustomerAddress' + CAST(@i AS CHAR),
      'Comments' + CAST(@i AS CHAR)
   )

   SET @i += 1
END
GO
SELECT * FROM Customers1
--------------------------------------------------------------------
/*
ایجاد جدول اول و درج دیتای تستی در آن
است Clustered Index در حالت دوم جدول دارای یک 
امکان درج مقدار تکراری به ازای کلید وجود دارد
*/
USE MyDB2017
GO
DROP TABLE IF EXISTS Customers2
GO

DROP TABLE IF EXISTS Customers2
GO
CREATE TABLE Customers2
( 
   CustomerID INT NOT NULL,
   CustomerName CHAR(100) NOT NULL,
   CustomerAddress CHAR(100) NOT NULL,
   Comments CHAR(181) NOT NULL
)
GO
--ایجاد یک کلاستر ایندکس 
CREATE CLUSTERED INDEX idx_Customers2_CustomerID
ON Customers2(CustomerID)
GO
--درج 80000 رکورد در جدول
SET NOCOUNT ON
DECLARE @i INT = 1
WHILE (@i <= 20000)
BEGIN
   INSERT INTO Customers2 VALUES
   (
      @i,
      'CustomerName' + CAST(@i AS CHAR),
      'CustomerAddress' + CAST(@i AS CHAR),
      'Comments' + CAST(@i AS CHAR)
   )
   INSERT INTO Customers2 VALUES
   (
      @i,
      'CustomerName' + CAST(@i AS CHAR),
      'CustomerAddress' + CAST(@i AS CHAR),
      'Comments' + CAST(@i AS CHAR)
   )
   INSERT INTO Customers2 VALUES
   (
      @i,
      'CustomerName' + CAST(@i AS CHAR),
      'CustomerAddress' + CAST(@i AS CHAR),
      'Comments' + CAST(@i AS CHAR)
   )
   INSERT INTO Customers2 VALUES
   (
      @i,
      'CustomerName' + CAST(@i AS CHAR),
      'CustomerAddress' + CAST(@i AS CHAR),
      'Comments' + CAST(@i AS CHAR)
   )

	SET @i += 1
END
GO
SELECT * FROM Customers2
--------------------------------------------------------------------
/*
مقایسه هر دو جدول از لحاظ حجم و ایندکس
اثبات اضافه شدن کلید 4 بایتی
*/
----------------------------------
--بررسی وجود رکورد تکراری
USE MyDB2017
GO
SELECT 
	CustomerID,COUNT(CustomerID) AS Cnt_Customer1 FROM Customers1
GROUP BY CustomerID
HAVING COUNT(*)>1
GO
SELECT 
	CustomerID,COUNT(CustomerID) AS Cnt_Customer1 FROM Customers2
GROUP BY CustomerID
HAVING COUNT(*)>1
GO
----------------------------------
USE MyDB2017
GO
--مقایسه حجم دو جدول
SP_SPACEUSED Customers1
GO
SP_SPACEUSED Customers2
GO
----------------------------------
--بررسی تعداد صفحات تخصیص یافته به دو جدول
SELECT 
	COUNT(*) AS Cnt_Customers1
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('Customers1'),
		NULL,NULL,'DETAILED'
	)
GO
SELECT 
	COUNT(*) AS Cnt_Customers2
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('Customers2'),
		NULL,NULL,'DETAILED'
	)
GO
----------------------------------
--مقایسه سطحوح ایندکس و صفحات تشکیل شده به ازای هر سطح
USE MyDB2017
GO
--آنالیز ایندکس جدول اول
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('Customers1'),
	1,
	NULL,
	'DETAILED'
)
GO
--آنالیز ایندکس جدول دوم
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('Customers2'),
	1,
	NULL,
	'DETAILED'
)
GO
--------------------------------------------------------------------
/*
اثبات اضافه شدن کلید 4 بایتی
*/
USE MyDB2017
GO
SELECT
   index_id,name,
   INDEXPROPERTY(object_id, name, 'keycnt80') AS KeyCnt_Customers1
FROM sys.indexes
WHERE object_id = OBJECT_ID ('Customers1');
GO
SELECT
   index_id,name,
   INDEXPROPERTY(object_id, name, 'keycnt80') AS KeyCnt_Customers2
FROM sys.indexes
WHERE object_id = OBJECT_ID ('Customers2');
GO
