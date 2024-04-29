
/*
Clustered Table بر روی جداول NonClustered Index ساخت  
*/

USE Index_DB;
GO

DROP TABLE IF EXISTS ClusteredTable;
GO
-- Heap ایجاد یک جدول از نوع
CREATE TABLE ClusteredTable
(
	ID CHAR(900),
	FirstName NCHAR(1750),
	LastName NCHAR(1750),
	BirthDay DATE
);
GO

-- ClusteredTable بر روی جدول Clustered ساخت ایندکس
CREATE CLUSTERED INDEX IX_Clustered ON ClusteredTable(ID);
GO

-- ClusteredTable بر روی جدول NonClustered ساخت ایندکس
CREATE NONCLUSTERED INDEX IX_NonClustered ON ClusteredTable(BirthDay);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

-- بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('Index_DB'),
	OBJECT_ID('ClusteredTable'),
	NULL,
	NULL,
	'DETAILED'
);
GO

-- درج تعدادی رکورد تستی
INSERT INTO ClusteredTable
	VALUES	(1, N'حمید', N'سعادت‌نژاد','1978-01-01'),
			(5, N'پریسا', N'یزدانیان','1983-03-21'),
			(3, N'علی', N'تقوی','1990-11-25'),
			(4, N'مجید', N'پاکروان','1983-09-16'),
			(2, N'فرهاد', N'رضایی','1994-11-04'),
			(10, N'زهرا', N'غفاری','1988-07-13'),
			(8, N'مهدی', N'پوینده','1985-12-06'),
			(9, N'سمانه', N'اکبری','1996-09-28'),
			(7, N'بیژن', N'تولایی','1990-05-13'),
			(6, N'فاطمه', N'شریفی','1984-08-13');
GO

/*
بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
! در یک فضای دیگر ایجاد شده است NonClustered ایندکس
*/
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('Index_DB'),
	OBJECT_ID('ClusteredTable'),
	NULL,
	NULL,
	'DETAILED'
);
GO
--------------------------------------------------------------------

-- آنالیز ایندکس

/*
صحفات وابسته به جدول
های تخصیص یافتهPage تعداد 
.را جداگانه داریم ClusteredTable ,NonClustered توجه شود که در درخت وابسته به ایندکس 
*/
SELECT 
	COUNT(*), page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
(
	DB_ID('Index_DB'),
	OBJECT_ID('ClusteredTable'),
	NULL,
	NULL,
	'DETAILED'
)
GROUP BY page_type_desc;
GO

/*
صحفات وابسته به جدول
.را جداگانه داریم ClusteredTable , NonClustered توجه شود که در درخت وابسته به ایندکس 
*/
SELECT 
	page_type_desc, allocated_page_page_id,
	next_page_page_id, previous_page_page_id
FROM sys.dm_db_database_page_allocations
(
	DB_ID('Index_DB'),
	OBJECT_ID('ClusteredTable'),
	NULL,
	NULL,
	'DETAILED'
)
GO
--------------------------------------------------------------------

--???
USE AdventureWorks2017;
GO

DROP TABLE IF EXISTS SalesOrderHeader2--SalesOrderDetail2;
GO
SELECT * INTO SalesOrderHeader2 FROM Sales.SalesOrderHeader;
GO

CREATE UNIQUE CLUSTERED INDEX IX_C_OrderDate ON SalesOrderHeader2(SalesOrderID);
GO

CREATE INDEX IX_NC_OrderDate ON SalesOrderHeader2(OrderDate);
GO

SELECT * FROM SalesOrderHeader2
	WHERE OrderDate = '2014-01-05';
GO

SELECT * FROM SalesOrderHeader2
	WHERE OrderDate = '2014-05-01';
GO

SELECT * FROM SalesOrderHeader2 WITH(INDEX(IX_NC_OrderDate))
	WHERE OrderDate = '2014-05-01';
GO