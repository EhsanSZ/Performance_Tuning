
/*
Bookmark بررسی مفهوم 
*/
GO
USE AdventureWorks2017
GO
--تهیه کپی از جدول
DROP TABLE IF EXISTS SalesOrderHeader_Heap
DROP TABLE IF EXISTS SalesOrderHeader_Clustered
GO
SELECT * INTO SalesOrderHeader_Heap FROM Sales.SalesOrderHeader
SELECT * INTO SalesOrderHeader_Clustered FROM Sales.SalesOrderHeader
GO
--------------------------------------------------------------------
--Heap بر روی جداول NonClustered Index ساخت 
CREATE INDEX IX_OrderDate ON SalesOrderHeader_Heap(OrderDate)
GO
--مشاهده ایندکس های ساخته شده روی جدول
SP_HELPINDEX SalesOrderHeader_Heap
GO
--ساخته شدن ایندکس در فضایی دیگر
SELECT 
	'00:00' AS RowID,
	OrderDate
FROM SalesOrderHeader_Heap 
ORDER BY OrderDate ASC
GO
--------------------------------------------------------------------
--Clustered بر روی جداول NonClustered Index ساخت 
GO
CREATE CLUSTERED INDEX IX_SalesOrderID ON SalesOrderHeader_Clustered(SalesOrderID)
CREATE INDEX IX_OrderDate ON SalesOrderHeader_Clustered(OrderDate)
GO
--مشاهده ایندکس های ساخته شده روی جدول
SP_HELPINDEX SalesOrderHeader_Clustered
GO
--ساخته شدن ایندکس در فضایی دیگر
SELECT 
	SalesOrderID AS RowID,
	OrderDate
FROM SalesOrderHeader_Clustered 
ORDER BY OrderDate ASC
GO
--------------------------------------------------------------------
--های مربوط به ایندکسPage آنالیز 
GO
--های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderHeader_Heap'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc
GO
--های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderHeader_Clustered'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc
GO
----------------------------------
--آنالیز ایندکس
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderHeader_Heap'),
	NULL,
	NULL,
	'DETAILED'
)
GO
--آنالیز ایندکس
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderHeader_Clustered'),
	NULL,
	NULL,
	'DETAILED'
)
GO
--------------------------------------------------------------------
