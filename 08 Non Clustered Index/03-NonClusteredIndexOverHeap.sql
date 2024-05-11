
/*
Heap بر روی جداول NonClustered Index ساخت  
*/
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
--Heap روی یک NonClustered Index ایجاد یک
GO
--بررسی وجود جدول
DROP TABLE IF EXISTS HeapTable
GO
--Heap ایجاد یک جدول از نوع
CREATE TABLE HeapTable
(
	ID CHAR(900),
	FirstName CHAR(3000),
	LastName CHAR(3000)
)
GO
--Clustered ساخت ایندکس
--پلن ساخت ایندکس بررسی و کوئری آن هم مشاهده شود

CREATE NONCLUSTERED INDEX IX_NonClustered ON HeapTable(ID)
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
		(DB_ID('MyDB2017'),OBJECT_ID('HeapTable'),NULL,NULL,'DETAILED') S
GO
--درج تعدادی رکورد تستی
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (1,'Masoud','Taheri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (5,'Alireza','Taheri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (3,'Ali','Taheri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (4,'Majid','Taheri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (2,'Farid','Taheri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (10,'Ahmad','Ghafari')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (8,'Alireza','Nasiri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (9,'Khadijeh','Afrooznia')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (7,'Mina','Afrooznia')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (6,'Mohammad','Noroozi')
GO
--بررسی حجم جدول
SP_SPACEUSED HeapTable
GO
--بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
--در یک فضای دیگر ایجاد شده استNonClustered ایندکس
SELECT 
	S.index_id,S.index_type_desc,
	S.index_depth,S.index_level,
	S.page_count ,S.record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('MyDB2017'),OBJECT_ID('HeapTable'),NULL,NULL,'DETAILED') S
GO
--------------------------------------------------------------------
--آنالیز ایندکس
GO
USE MyDB2017
GO
/*
صحفات وابسته به جدول
های تخصیص یافته ، هر کدام از آنها به تفکیک شرح داده شودPage تعداد 
را جداگانه داریمHeap , NonClustered توجه شود که در درخت وابسته به ایندکس 
*/
GO
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('HeapTable'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc
GO
/*
صحفات وابسته به جدول
را جداگانه داریمHeap , NonClustered توجه شود که در درخت وابسته به ایندکس 
*/
SELECT 
	page_type_desc,allocated_page_page_id,
	next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('HeapTable'),
		NULL,NULL,'DETAILED'
	)
GO
