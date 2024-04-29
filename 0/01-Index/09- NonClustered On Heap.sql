
/*
Heap بر روی جداول NonClustered Index ساخت  
*/

USE Index_DB;
GO

DROP TABLE IF EXISTS HeapTable;
GO
-- Heap ایجاد یک جدول از نوع
CREATE TABLE HeapTable
(
	ID CHAR(900),
	FirstName NCHAR(1750),
	LastName NCHAR(1750)
);
GO

-- Heap بر روی جدول NonClustered ساخت ایندکس
CREATE NONCLUSTERED INDEX IX_NonClustered ON HeapTable(ID);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX HeapTable;
GO

-- بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('Index_DB'),
	OBJECT_ID('HeapTable'),
	NULL,
	NULL,
	'DETAILED'
);
GO

-- درج تعدادی رکورد تستی
INSERT INTO HeapTable
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(7, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
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
	OBJECT_ID('HeapTable'),
	NULL,
	NULL,
	'DETAILED'
);
GO
--------------------------------------------------------------------

/*
آنالیز ایندکس
صحفات وابسته به جدول
.های تخصیص یافته، هر کدام از آنها به تفکیک شرح داده شودPage تعداد 
.را جداگانه داریم Heap , NonClustered توجه شود که در درخت وابسته به ایندکس 
*/

SELECT 
	COUNT(*), page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
(
	DB_ID('Index_DB'),
	OBJECT_ID('HeapTable'),
	NULL,
	NULL,
	'DETAILED'
)
GROUP BY page_type_desc;
GO

/*
صحفات وابسته به جدول
.را جداگانه داریم Heap , NonClustered توجه شود که در درخت وابسته به ایندکس 
*/
SELECT 
	page_type_desc, allocated_page_page_id,
	next_page_page_id, previous_page_page_id
FROM sys.dm_db_database_page_allocations
(
	DB_ID('Index_DB'),
	OBJECT_ID('HeapTable'),
	NULL,
	NULL,
	'DETAILED'
);
GO