
USE AdventureWorks2017;
GO

/*
Heap بر روی Cover Index ایجاد
*/

DROP TABLE IF EXISTS HeapTable;
GO
-- Heap ایجاد یک جدول از نوع
SELECT * INTO HeapTable FROM Sales.SalesOrderDetail;
GO

-- Composit Index ایجاد
CREATE NONCLUSTERED INDEX NCIX_PidOqSoid ON HeapTable(ProductID,OrderQty,SpecialOfferID);
GO

SET STATISTICS IO ON;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable
	WHERE ProductID = 789;
GO

-- CoverIndex ایجاد
CREATE NONCLUSTERED INDEX NCIX_PidOqSoid_SidSodid ON HeapTable(ProductID,OrderQty,SpecialOfferID)
INCLUDE(SalesOrderID,SalesOrderDetailID);
GO

-- مقایسه کوئری‌های زیر
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable WITH(INDEX(NCIX_PidOqSoid))
	WHERE ProductID = 789;
GO

-- .با توجه به کوئری می‌توانستیم ایندکس را به‌صورت زیر هم ایجاد کنیم
CREATE NONCLUSTERED INDEX NCIX_Pid_SoidSodidOqSoid ON HeapTable (ProductID)
INCLUDE (SalesOrderID,SalesOrderDetailID,OrderQty,SpecialOfferID);
GO

-- مقایسه کوئری‌های زیر
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM HeapTable WITH(INDEX(NCIX_PidOqSoid_SidSodid))
	WHERE ProductID = 789;
GO
--------------------------------------------------------------------

/*
Clustered Table بر روی Cover Index ایجاد
*/

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS ClusteredTable;
GO

-- Heap ایجاد یک جدول از نوع
SELECT * INTO ClusteredTable FROM Sales.SalesOrderDetail;
GO

-- ایجاد ایندکس روی جدول
CREATE CLUSTERED INDEX CIX_SalesOrderID ON ClusteredTable(SalesOrderID);
CREATE NONCLUSTERED INDEX NCIX_PidOqSoid ON ClusteredTable(ProductID,OrderQty,SpecialOfferID);
GO

-- مقایسه کوئری‌های زیر
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
FROM ClusteredTable WITH(INDEX(CIX_SalesOrderID))
	WHERE ProductID = 789;
GO

-- Cover Index ایجاد
CREATE NONCLUSTERED INDEX NCIX_PidOqSoid_Sodid ON ClusteredTable(ProductID,OrderQty,SpecialOfferID)
INCLUDE(SalesOrderDetailID);
GO

-- مقایسه کوئری‌های زیر
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
FROM ClusteredTable WITH(INDEX(NCIX_PidOqSoid))
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable WITH(INDEX(CIX_SalesOrderID))
	WHERE ProductID = 789;
GO

-- .با توجه به کوئری می‌توانستیم ایندکس را به‌صورت زیر هم ایجاد کنیم
CREATE NONCLUSTERED INDEX NCIX_Pid_SoidSodidOqSoid ON ClusteredTable (ProductID)
INCLUDE (SalesOrderID,SalesOrderDetailID,OrderQty,SpecialOfferID);
GO

-- مقایسه کوئری‌های زیر
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable WITH(INDEX(NCIX_PidOqSoid_Sodid))
	WHERE ProductID = 789;
GO
--------------------------------------------------------------------

-- Disable Index
ALTER INDEX [Index_Name] ON [Table_Name] DISABLE;
GO

-- Enable Index
ALTER INDEX [Index_Name] ON [Table_Name] REBUILD;
GO