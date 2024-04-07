
/*
RID Lookup بررسی مفهوم 
*/

USE AdventureWorks2017;
GO
 
DROP TABLE IF EXISTS  HeapTable;
GO
-- Heap ایجاد یک جدول از نوع
SELECT * INTO HeapTable FROM Sales.SalesOrderDetail;
GO

-- ایجاد ایندکس روی جدول
CREATE NONCLUSTERED INDEX IX_NonClustered ON HeapTable(ProductID,OrderQty,SpecialOfferID);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX HeapTable;
GO

SET STATISTICS IO ON;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable
	WHERE ProductID = 789;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable
	WHERE OrderQty = 1;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable
	WHERE ProductID = 789
	AND OrderQty = 1;
GO
--------------------------------------------------------------------

/*
Key Lookup بررسی مفهوم 
*/

DROP TABLE IF EXISTS ClusteredTable;
GO
-- Heap ایجاد یک جدول از نوع
SELECT * INTO ClusteredTable FROM Sales.SalesOrderDetail;
GO

-- ایجاد ایندکس روی جدول
CREATE CLUSTERED INDEX IX_Clustered ON ClusteredTable(SalesOrderID);
CREATE NONCLUSTERED INDEX IX_NonClustered ON ClusteredTable(ProductID,OrderQty,SpecialOfferID);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

SELECT
	SalesOrderID,
	SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable
	WHERE ProductID = 789;
GO
--------------------------------------------------------------------

-- RID Lookup نسبت به Key Lookup مربوط به IO مقایسه
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable
	WHERE ProductID = 789;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable
	WHERE ProductID = 789;
GO
--------------------------------------------------------------------

-- Non Clustered Index مقایسه استفاده و یا عدم استفاده از 

-- Heap Table
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable WITH (INDEX(0))
	WHERE ProductID = 789;
GO

-- Clustered Table
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable WITH(INDEX(0))
	WHERE ProductID = 789;
GO