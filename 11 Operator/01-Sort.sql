
/*
Sort بررسی
مرتب سازی داده ها
*/
GO
/*
Sort بررسی برخی از حالت های به وجود آمدن 
Execution Plan , IO مشاهده 
*/
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
GO
USE AdventureWorks2017
GO
--Order by استفاده از صریح از 
SELECT  
	* 
FROM Sales.SalesOrderHeader
ORDER BY 
	OrderDate
GO
/*
Sort استفاده غیر مستقیم از 
می شوند Sort نوشتن دستوراتی که باعث استفاده از اپراتور 
*/
USE AdventureWorks2017
GO
--Query 1
SELECT  DISTINCT
	Color
FROM Production.Product
GO
--Query 2
SELECT 
	Product.Class,COUNT(*)
FROM Production.Product
GROUP BY 
	Product.Class
GO
--------------------------------------------------------------------
/*
Sort نحوه رفع مشکلات اپراتور 
*/
USE tempdb
GO
--بررسی وجود جدول و حذف آن 
DROP TABLE IF EXISTS Store
GO
--ایجاد جدول تستی
CREATE TABLE Store
(
    StoreID INT NOT NULL IDENTITY (1, 1),
    ParentStoreID INT NULL,
    StoreType INT NULL,
    Phone CHAR(10) NULL,
    PRIMARY KEY (StoreID)
)
GO
--درج تعدادی رکورد تستی در جدول
INSERT INTO Store (ParentStoreID, StoreType, Phone) VALUES (10, 0, '2223334444')
INSERT INTO Store (ParentStoreID, StoreType, Phone) VALUES (10, 0, '3334445555')
INSERT INTO Store (ParentStoreID, StoreType, Phone) VALUES (10, 1, '0001112222')
INSERT INTO Store (ParentStoreID, StoreType, Phone) VALUES (10, 1, '1112223333')
GO
--مشاهده رکوردهای درج شده در جدول
SELECT * FROM Store
GO
/*
Execution Plan , IO مشاهده 
حذف هزینه مرتب سازی
*/
SELECT 
	Phone
FROM dbo.Store
WHERE
	ParentStoreId = 10
	AND (StoreType = 0 OR StoreType = 1)
ORDER BY Phone
GO
--Execution Plan ساخت ایندکس و بررسی مجدد 
CREATE INDEX IX_Store ON Store (Phone) INCLUDE(ParentStoreId, StoreType)
GO
--پاک کردن ایندکس
DROP INDEX IX_Store ON Store 
GO
--Execution Plan ساخت ایندکس و بررسی مجدد 
CREATE INDEX IX_Store ON Store(ParentStoreId, StoreType, Phone)
GO
--------------------------------------------------------------------
/*
Sort Warning مسئاله تخمین اشتباه و به وجود آمدن مشکل 

IO,Execution Plan بررسی 
ها Warning برای پیدا کردن این نوع Profiler استفاده از برنامه 
*/
SET STATISTICS TIME ON 
SET STATISTICS IO ON
GO
USE AdventureWorks2017
GO
--Query 1
SELECT 
	*
FROM Sales.SalesOrderHeader
WHERE DueDate > ShipDate
ORDER BY OrderDate
GO
--Query 2
DECLARE @OrderDate DATETIME='2001-01-01'
SELECT 
	*
FROM Sales.SalesOrderHeader
WHERE OrderDate > @OrderDate
ORDER BY DueDate
GO
--Query 3
SELECT 
	*
FROM Sales.SalesOrderHeader
WHERE OrderDate >'2001-01-01'
ORDER BY DueDate;
GO
--------------------------------------------------------------------
/*
تمرین 1
Sort مبحث مربوط به 
*/
/*
USE AdventureWorks2017
GO
DROP TABLE IF EXISTS TransactionHistory2 
GO
SELECT * INTO TransactionHistory2 FROM Production.TransactionHistory
GO 
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON TransactionHistory2(TransactionID) WITH (DROP_EXISTING=ON)
GO
SELECT TOP 100
	* 
FROM TransactionHistory2
ORDER BY 
	TransactionDate DESC
GO
*/