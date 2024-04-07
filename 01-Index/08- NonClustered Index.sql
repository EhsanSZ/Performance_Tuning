
USE AdventureWorks2017;
GO

DROP TABLE IF EXISTS SalesOrderDetail2;
GO
-- Sales.SalesOrderDetail تهیه کپی از جدول
DROP TABLE IF EXISTS SalesOrderDetail2;
GO

SELECT * INTO SalesOrderDetail2 FROM Sales.SalesOrderDetail;
GO

/*
ProductID اعمال جستجو بر روی فیدل 
IO, Execution Plan بررسی 
*/
SET STATISTICS IO ON;
GO

SELECT * FROM SalesOrderDetail2
	WHERE ProductID = 900;
GO
--------------------------------------------------------------------

-- SalesOrderDetail2 بر روی جدول NONCLUSTERED INDEX ایجاد
CREATE NONCLUSTERED INDEX IX_ProductID ON SalesOrderDetail2(ProductID);
GO
/*
.معادل دستور بالا است
CREATE INDEX IX_ProductID ON SalesOrderDetail2(ProductID);
GO
*/

-- مشاهده ایندکس
SP_HELPINDEX SalesOrderDetail2;
GO

-- IO, Execution Plan بررسی 
SELECT * FROM SalesOrderDetail2
	WHERE ProductID = 900;
GO
--------------------------------------------------------------------

-- IO, Execution Plan بررسی 
SELECT * FROM SalesOrderDetail2
	WHERE ProductID = 900;
GO
SELECT * FROM SalesOrderDetail2 WITH(INDEX(0))
	WHERE ProductID = 900;
GO
--------------------------------------------------------------------

/*
بررسی ساخت ایندکس در یک فضای دیگر
*/

SET STATISTICS IO OFF;
GO

DROP TABLE IF EXISTS SalesOrderDetail2;
GO
-- Sales.SalesOrderDetail تهیه کپی از جدول
SELECT * INTO SalesOrderDetail2 FROM Sales.SalesOrderDetail;
GO

-- SalesOrderDetail2 های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*), page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderDetail2'),
	NULL,
	NULL,
	'DETAILED'
)
GROUP BY page_type_desc;
GO

-- SalesOrderDetail2 بر روی جدول NONCLUSTERED INDEX ایجاد
CREATE NONCLUSTERED INDEX IX_ProductID ON SalesOrderDetail2(ProductID);
GO

-- SalesOrderDetail2 های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*), page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderDetail2'),
	NULL,
	NULL,
	'DETAILED'
)
GROUP BY page_type_desc;
GO

-- اصل رکوردهای جدول
SELECT * FROM SalesOrderDetail2;
GO

-- NonClustered شبیه‌سازی در فضای
SELECT 'Other Info', ProductID FROM SalesOrderDetail2
	ORDER BY ProductID;
GO

-- آنالیز ایندکس
SELECT
	index_type_desc, index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderDetail2'),
	NULL,
	NULL,
	'DETAILED'
);
GO
--------------------------------------------------------------------

USE Index_DB;
GO

DROP TABLE IF EXISTS Employees;
GO
-- ایجاد جدول تستی
CREATE TABLE Employees
(
	ID CHAR(900),
	FirstName NVARCHAR(3000),
	LastName NVARCHAR(3000),
	StartYear CHAR(900)
);
GO

-- NonClustered Index بررسی ساخت 999 عدد  
DECLARE @Cmd VARCHAR(1000);
DECLARE @Cnt INT = 1;
WHILE @Cnt <= 1000
BEGIN 
	SET @Cmd='CREATE NONCLUSTERED INDEX IX_'+ CAST(@Cnt AS VARCHAR(100))+' ON Employees(StartYear)'
	PRINT @CMD
	EXEC( @Cmd)
	SET @Cnt += 1
END;
GO

-- مشاهده ایندکس‌های جدول‎‌
SP_HELPINDEX Employees;
GO
--------------------------------------------------------------------

/*
SQL Server بررسی افزایش طول کلید ایندکس در 
تست در حالت های
CHAR,NCHAR,NVARCHAR,
*/

DROP TABLE IF EXISTS Employees;
GO
-- ایجاد جدول تستی
CREATE TABLE Employees
(
	ID CHAR(900),
	FirstName NVARCHAR(3000),
	LastName NVARCHAR(3000),
	Barcode CHAR(1700) --NCHAR \ NVARCHAR
);
GO

CREATE INDEX IX_Barcode ON Employees(Barcode);
GO