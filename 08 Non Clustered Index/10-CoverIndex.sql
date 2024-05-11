
USE tempdb
GO
--Heap بر رویCover Index ایجاد
GO
--بررسی وجود جدول
DROP TABLE IF EXISTS HeapTable
GO
--Heap ایجاد یک جدول از نوع
SELECT * INTO HeapTable FROM AdventureWorks2017.Sales.SalesOrderDetail
GO
--ایجاد ایندکس روی جدول
CREATE NONCLUSTERED INDEX IX_NonClustered01 ON HeapTable(ProductID,OrderQty,SpecialOfferID)
GO
--Execution Plan بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM HeapTable WHERE ProductID = 789
GO
--CoverIndex ایجاد
--INCLUDE و OutputList بررسی ارتباط فیلدهای 
CREATE NONCLUSTERED INDEX IX_NonClustered02 
	ON HeapTable(ProductID,OrderQty,SpecialOfferID)
		INCLUDE(SalesOrderID,SalesOrderDetailID)
GO
/*
CREATE NONCLUSTERED INDEX IX_NonClustered02
ON HeapTable (ProductID)
INCLUDE (SalesOrderID,SalesOrderDetailID,OrderQty,SpecialOfferID)
*/
GO
--Execution Plan بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM HeapTable WHERE ProductID = 789
GO
--Execution Plan مقایسه
SET STATISTICS IO ON
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM HeapTable WITH(INDEX(IX_NonClustered01)) WHERE ProductID = 789
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM HeapTable WHERE ProductID = 789
GO
SET STATISTICS IO OFF
GO
--بررسی تعداد ظرفیت و تعداد صفحات تخصیص یافته به ازای ایندکس ها
SELECT 
	S.index_id,S.index_type_desc,
	S.index_depth,S.index_level,
	S.page_count ,S.record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('tempdb'),OBJECT_ID('HeapTable'),NULL,NULL,'DETAILED') S
GO
----------------------------------------------------------------------------
--Clustered Table بر رویCover Index ایجاد
USE tempdb
GO
--بررسی وجود جدول
DROP TABLE IF EXISTS ClusteredTable
GO
--Heap ایجاد یک جدول از نوع
SELECT * INTO ClusteredTable FROM AdventureWorks2017.Sales.SalesOrderDetail
GO
--ایجاد ایندکس روی جدول
CREATE CLUSTERED INDEX IX_Clustered ON ClusteredTable(SalesOrderID)
CREATE NONCLUSTERED INDEX IX_NonClustered01 ON ClusteredTable(ProductID,OrderQty,SpecialOfferID)
GO
--Execution Plan بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM ClusteredTable WHERE ProductID = 789
GO
--CoverIndex ایجاد
--INCLUDE و OutputList بررسی ارتباط فیلدهای 
CREATE NONCLUSTERED INDEX IX_NonClustered02 
	ON ClusteredTable(ProductID,OrderQty,SpecialOfferID)
		INCLUDE(SalesOrderDetailID) --with (drop_existing=on)
/*
--چرا نوشته نشد
INCLUDE(SalesOrderID,SalesOrderDetailID)
--... کلید کلاستر در 
*/
GO
/*
CREATE NONCLUSTERED INDEX IX_NonClustered02
ON ClusteredTable (ProductID)
INCLUDE (SalesOrderID,SalesOrderDetailID,OrderQty,SpecialOfferID)
*/
GO
--Execution Plan بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM ClusteredTable WHERE ProductID = 789
GO
--Execution Plan مقایسه
SET STATISTICS IO ON
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM ClusteredTable WITH(INDEX(IX_NonClustered01)) WHERE ProductID = 789
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM ClusteredTable WHERE ProductID = 789
GO
SET STATISTICS IO OFF
GO
--بررسی تعداد ظرفیت و تعداد صفحات تخصیص یافته به ازای ایندکس ها
SELECT 
	S.index_id,S.index_type_desc,
	S.index_depth,S.index_level,
	S.page_count ,S.record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('tempdb'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED') S
GO
-----------------------------------------------------------
--و کلاستر Heap در جداول Cover Index مقایسه ای بین
GO
SET STATISTICS IO ON 
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM HeapTable WHERE ProductID = 789
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM ClusteredTable WHERE ProductID = 789
GO
