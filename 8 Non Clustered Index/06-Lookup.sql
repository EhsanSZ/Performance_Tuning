-
/*
Lookup بررسی مفهوم 
*/
GO
USE tempdb
GO
--RID Lookup مشاهده
GO
--بررسی وجود جدول
DROP TABLE IF EXISTS  HeapTable
GO
--Heap ایجاد یک جدول از نوع
SELECT * INTO HeapTable FROM AdventureWorks2017.Sales.SalesOrderDetail
GO
--ایجاد ایندکس روی جدول
CREATE NONCLUSTERED INDEX IX_NonClustered ON HeapTable(ProductID,OrderQty,SpecialOfferID)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX HeapTable 
GO
--بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
SELECT 
	S.index_id,S.index_type_desc,
	S.index_depth,S.index_level,
	S.page_count ,S.record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('tempdb'),OBJECT_ID('HeapTable'),NULL,NULL,'DETAILED') S
GO
--بررسی حجم جدول
SP_SPACEUSED HeapTable
GO
--Execution Plan بررسی
--و تعداد رکوردهای بازگشتی Estimate Number Of Execution بررسی 
--Output List بررسی
SET STATISTICS IO ON
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM HeapTable WHERE ProductID = 789
GO
----------------------------------------------------------------------------
--Key Lookup مشاهده
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
CREATE NONCLUSTERED INDEX IX_NonClustered ON ClusteredTable(ProductID,OrderQty,SpecialOfferID)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable 
GO
--بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
SELECT 
	S.index_id,S.index_type_desc,
	S.index_depth,S.index_level,
	S.page_count ,S.record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('tempdb'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED') S
GO
--بررسی حجم جدول
SP_SPACEUSED ClusteredTable
GO
--Execution Plan بررسی
--و تعداد رکوردهای بازگشتی Estimate Number Of Execution بررسی 
--Output List بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM ClusteredTable WHERE ProductID = 789
GO
-----------------------------------------------------------
--RID Lookup & Key Lookup مقایسه ای بین 
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
--چرا؟
/*
HeapTable(ProductID,OrderQty,SpecialOfferID) *NONCLUSTERED
ClusteredTable(SalesOrderID) *CLUSTERED
ClusteredTable(ProductID,OrderQty,SpecialOfferID) *NONCLUSTERED
*/
--Show Execution Plan
GO
-----------------------------------------------------------
--Non Clustered Index مقایسه استفاده و یا عدم استفاده از 
USE tempdb
GO
--Heap Table
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM HeapTable WITH (INDEX(0)) WHERE ProductID = 789
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM HeapTable WHERE ProductID = 789
GO
--Clustered Table
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM ClusteredTable WITH(INDEX(0)) WHERE ProductID = 789
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty,SpecialOfferID
FROM ClusteredTable WHERE ProductID = 789
GO
--------------------------------------------------------------------
/*
--تمرین 4
USE AdventureWorks2017
GO
--تهیه کپی از جدول
DROP TABLE IF EXISTS SalesOrderHeader_Clustered
GO
SELECT * INTO SalesOrderHeader_Clustered FROM Sales.SalesOrderHeader
GO
--Clustered بر روی جداول NonClustered Index ساخت 
CREATE CLUSTERED INDEX IX_SalesOrderID ON SalesOrderHeader_Clustered(SalesOrderID)
CREATE INDEX IX_OrderDate ON SalesOrderHeader_Clustered(OrderDate)
GO

SET STATISTICS IO ON 

SELECT * FROM   SalesOrderHeader_Clustered WHERE OrderDate='2017-01-01'
GO
SELECT * FROM   SalesOrderHeader_Clustered WHERE OrderDate='2017-01-01'
GO
SELECT * FROM   SalesOrderHeader_Clustered WHERE OrderDate='2011-07-27'
GO

*/