
--Heap Table بررسی محاسن 
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
USE MyDB2017
GO
--Heap ایجاد یک جدول از نوع 
DROP TABLE IF EXISTS SalesOrderDetail_Heap
GO
CREATE TABLE SalesOrderDetail_Heap
(
	SalesOrderID int NOT NULL,
	SalesOrderDetailID int ,
	CarrierTrackingNumber nvarchar(25) NULL,
	OrderQty smallint NULL,
	ProductID int NULL,
	SpecialOfferID int NULL,
	UnitPrice money  NULL,
	UnitPriceDiscount money ,
	LineTotal  money,
	rowguid uniqueidentifier ,
	ModifiedDate datetime 
)
GO
--Clustered ایجاد یک جدول از نوع 
DROP TABLE IF EXISTS SalesOrderDetail_Clustered
GO
CREATE TABLE SalesOrderDetail_Clustered
(
	SalesOrderID int NOT NULL,
	SalesOrderDetailID int ,
	CarrierTrackingNumber nvarchar(25) NULL,
	OrderQty smallint NULL,
	ProductID int NULL,
	SpecialOfferID int NULL,
	UnitPrice money  NULL,
	UnitPriceDiscount money ,
	LineTotal  money,
	rowguid uniqueidentifier ,
	ModifiedDate datetime 
)
GO
--ایجاد کلاستر ایندکس به ازای جدول
CREATE CLUSTERED INDEX IX_Clustered ON SalesOrderDetail_Clustered (SalesOrderID,SalesOrderDetailID)
GO
--------------------------------------------------------------------
--بررسی رکوردهای موجود در جدول
SELECT  
	SalesOrderID
    ,SalesOrderDetailID
    ,CarrierTrackingNumber
    ,OrderQty
    ,ProductID
    ,SpecialOfferID
    ,UnitPrice
    ,UnitPriceDiscount
    ,LineTotal
    ,rowguid
    ,ModifiedDate
FROM AdventureWorks2017.Sales.SalesOrderDetail
GO
--------------------------------------------------------------------
--Heap درج دیتا در جدول 
INSERT INTO SalesOrderDetail_Heap
(
	SalesOrderID
    ,SalesOrderDetailID
    ,CarrierTrackingNumber
    ,OrderQty
    ,ProductID
    ,SpecialOfferID
    ,UnitPrice
    ,UnitPriceDiscount
    ,LineTotal
    ,rowguid
    ,ModifiedDate
)
SELECT  
	SalesOrderID
    ,SalesOrderDetailID
    ,CarrierTrackingNumber
    ,OrderQty
    ,ProductID
    ,SpecialOfferID
    ,UnitPrice
    ,UnitPriceDiscount
    ,LineTotal
    ,rowguid
    ,ModifiedDate
FROM AdventureWorks2017.Sales.SalesOrderDetail
GO 10
--Clustered درج دیتا در جدول 
INSERT INTO SalesOrderDetail_Clustered
(
	SalesOrderID
    ,SalesOrderDetailID
    ,CarrierTrackingNumber
    ,OrderQty
    ,ProductID
    ,SpecialOfferID
    ,UnitPrice
    ,UnitPriceDiscount
    ,LineTotal
    ,rowguid
    ,ModifiedDate
)
SELECT  
	SalesOrderID
    ,SalesOrderDetailID
    ,CarrierTrackingNumber
    ,OrderQty
    ,ProductID
    ,SpecialOfferID
    ,UnitPrice
    ,UnitPriceDiscount
    ,LineTotal
    ,rowguid
    ,ModifiedDate
FROM AdventureWorks2017.Sales.SalesOrderDetail
GO 10
--------------------------------------------------------------------
--مشاهده فضای تخصیص یافته به جداول
SP_SPACEUSED SalesOrderDetail_Heap
GO
SP_SPACEUSED SalesOrderDetail_Clustered
GO
--Heap های مربوط به جدول Pageبررسی 
SELECT 
	COUNT(*)
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('SalesOrderDetail_Heap'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--Clustered های مربوط به جدول Pageبررسی 
SELECT 
	COUNT(*)
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('SalesOrderDetail_Clustered'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
/*
--پبج اضافی کلاستر مربوط به 
1- ساختار کلاستر ایندکس
2- Index Fragmentation
*/