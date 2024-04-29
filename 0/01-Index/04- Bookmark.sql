USE AdventureWorks2017
GO

DROP TABLE IF EXISTS SalesOrderHeader_Heap;
DROP TABLE IF EXISTS SalesOrderHeader_Clustered;
GO
-- تهیه کپی از جداول
SELECT * INTO SalesOrderHeader_Heap FROM Sales.SalesOrderHeader;
SELECT * INTO SalesOrderHeader_Clustered FROM Sales.SalesOrderHeader;
GO
--------------------------------------------------------------------

-- Heap بر روی جدول NonClustered Index ساخت 
CREATE INDEX IX_OrderDate ON SalesOrderHeader_Heap(OrderDate);
GO

-- مشاهده ایندکس های ساخته شده روی جدول
SP_HELPINDEX SalesOrderHeader_Heap;
GO

-- SalesOrderHeader_Heap بر روی جدول NonClustered شبیه‌سازی فضای ساخته‌شده با ایندکس
SELECT 
	'00:00' AS RowID,
	OrderDate
FROM SalesOrderHeader_Heap 
ORDER BY OrderDate;
GO
--------------------------------------------------------------------

-- Clustered بر روی جدول NonClustered Index ساخت 
CREATE CLUSTERED INDEX IX_SalesOrderID ON SalesOrderHeader_Clustered(SalesOrderID);
CREATE INDEX IX_OrderDate ON SalesOrderHeader_Clustered(OrderDate);
GO

-- مشاهده ایندکس های ساخته شده روی جدول
SP_HELPINDEX SalesOrderHeader_Clustered;
GO

-- SalesOrderHeader_Clustered بر روی جدول NonClustered شبیه‌سازی فضای ساخته‌شده با ایندکس
SELECT 
	SalesOrderID AS Clustered_Key,
	OrderDate
FROM SalesOrderHeader_Clustered 
ORDER BY OrderDate;
GO

-- آنالیز ایندکس
SELECT 
	index_type_desc, index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderHeader_Heap'),
	NULL,
	NULL,
	'DETAILED'
);
GO

-- آنالیز ایندکس
SELECT 
	index_type_desc, index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderHeader_Clustered'),
	NULL,
	NULL,
	'DETAILED'
);
GO