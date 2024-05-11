
--بررسی معایب هیپ

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
--برای محاسبه فضای خالی و عدم تجزیه و تحلیل فضای خالیPFS استفاده از 
--باعث هدر رفتن فضای زیادی خواهد شد اگر اندازه رکوردها زیاد باشد
GO
USE MyDB2017
GO
--ایجاد جدول تستی
DROP TABLE IF EXISTS Heap_PFS
GO
CREATE TABLE Heap_PFS
(
	Val VARCHAR(8000) NOT NULL
)
GO
--درج 20 رکورد تستی با حجم نسبتا زیاد در جدول
--حجم رکوردهای نسبتا زیاد است
WITH CTE(ID,Val)
AS
(
	SELECT 1, REPLICATE('0',4089)
	UNION ALL
	SELECT ID + 1, VAL FROM CTE WHERE ID < 20
)
INSERT INTO Heap_PFS
	SELECT Val FROM CTE
GO
SELECT * FROM Heap_PFS
GO
--محاسبه فضای تخصیص یافته به جدول
---مشخص می شود 51-80درصد صفحات پر است PFS با توجه به ستون آخر و تصویر 
SELECT 
	page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(db_id('MyDB2017'),object_id(N'Heap_PFS'),NULL,NULL,'DETAILED')
GO
--صحفات وابسته به جدول
SELECT 
	page_type_desc,allocated_page_page_id, extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('Heap_PFS'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--PFS Page مشاهده محتوای
DBCC TRACEON (3604);
DBCC PAGE ('MyDB2017', 1, 1, 3)
GO
SELECT  [Current LSN],
     Operation,
     Context,
     AllocUnitId,
     AllocUnitName,
     [Page ID],
     [Slot ID]       
FROM    sys.fn_dblog(NULL, NULL)
WHERE   AllocUnitName = 'dbo.Heap_PFS' OR
        Context = 'LCX_PFS'
ORDER BY
        [Current LSN];
GO
------
--درج رکورد جدید حجم آنها نسبتا کم است
--رکورد متناسب با جدول است PFS با توجه به مقدار
INSERT INTO Heap_PFS(Val) VALUES(REPLICATE('1',100))
GO
--محاسبه فضای تخصیص یافته به جدول
---مشخص می شود 51-80درصد صفحات پر است PFS با توجه به ستون آخر و تصویر 
SELECT 
	page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(db_id('MyDB2017'),object_id(N'Heap_PFS'),NULL,NULL,'DETAILED')
GO
------
--درج رکورد جدید حجم آنها نسبتا زیاد است
--رکورد متناسب با جدول نمی باشد PFS با توجه به مقدار
INSERT INTO Heap_PFS(Val) VALUES(REPLICATE('2',2000))
GO
--محاسبه فضای تخصیص یافته به جدول
SELECT 
	page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(db_id('MyDB2017'),object_id(N'Heap_PFS'),NULL,NULL,'DETAILED')
GO
SELECT * FROM Heap_PFS
GO
--این مشکل در جداول کلاستر وجود ندارد
