
USE AdventureWorks2017
GO
--تهیه کپی از جدول
DROP TABLE IF EXISTS SalesOrderDetail2
GO
SELECT * INTO SalesOrderDetail2 FROM Sales.SalesOrderDetail
GO
/*
ProductID اعمال جستجو بر روی فیدل 
IO, Execution Plan بررسی 
*/
SET STATISTICS IO ON 
GO
SELECT * FROM SalesOrderDetail2 WHERE ProductID=985
GO
----------------------------------
/*
NonClustered Index ساخت 
بود و نبودش تاثیری ندارد NonClustered کلمه 
GO
پلن ساخت ایندکس بررسی و کوئری آن هم مشاهده شود
*/
CREATE NONCLUSTERED INDEX IX_ProductID ON SalesOrderDetail2(ProductID)
GO
--مشاهده ایندکس
SP_HELPINDEX SalesOrderDetail2
GO
/*
ProductID اعمال جستجو بر روی فیدل 
IO, Execution Plan بررسی 
*/
SET STATISTICS IO ON 
GO
SELECT * FROM SalesOrderDetail2 WHERE ProductID=985
GO
----------------------------------
/*
NonClustered Index , Heap مقایسه استفاده از 
IO, Execution Plan بررسی 
*/
SET STATISTICS IO ON 
GO
SELECT * FROM SalesOrderDetail2 WITH (INDEX(0)) 
	WHERE ProductID=985
GO
SELECT * FROM SalesOrderDetail2 
	WHERE ProductID=985
GO
--------------------------------------------------------------------
/*
بررسی ساخت ایندکس در یک فضای دیگر
*/
USE AdventureWorks2017
GO
--بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS SalesOrderDetail2
GO
--تهیه کپی از جدول
SELECT * INTO SalesOrderDetail2 FROM Sales.SalesOrderDetail
GO
--های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderDetail2'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc
GO
--ساخت ایندکس
CREATE NONCLUSTERED INDEX IX_ProductID ON SalesOrderDetail2(ProductID)
GO
--های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderDetail2'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc
GO
/*
بررسی وضعیت ایندکس 
*/
--اصل رکوردهای جدول
SELECT * FROM SalesOrderDetail2
GO
SELECT 'Other Info',ProductID FROM SalesOrderDetail2
	ORDER BY ProductID
GO
/*
تشکیل سطوح ایندکس در فضایی جداگانه
آنالیز ایندکس
*/
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderDetail2'),
	NULL,
	NULL,
	'DETAILED'
)
GO
