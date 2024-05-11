
/*
Clustered Table بر روی جداول NonClustered Index ساخت  
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
DROP TABLE IF EXISTS ClusteredTable
GO
--Heap ایجاد یک جدول از نوع
CREATE TABLE ClusteredTable
(
	ID CHAR(900),
	FirstName CHAR(3000),
	LastName CHAR(3000),
	StartYear  CHAR(900)
)
GO
--Clustered ساخت ایندکس
--پلن ساخت ایندکس بررسی و کوئری آن هم مشاهده شود
CREATE CLUSTERED INDEX IX_Clustered ON ClusteredTable(ID)
GO
--NonClustered ساخت ایندکس
--پلن ساخت ایندکس بررسی و کوئری آن هم مشاهده شود
CREATE NONCLUSTERED INDEX IX_NonClustered ON ClusteredTable(StartYear)
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
		(DB_ID('MyDB2017'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED') S
GO
--درج تعدادی رکورد تستی
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (1,'Masoud','Taheri',1378)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (5,'Alireza','Taheri',1393)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (3,'Ali','Taheri',1390)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (4,'Majid','Taheri',1380)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (2,'Farid','Taheri',1378)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (10,'Ahmad','Ghafari',1379)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (8,'Alireza','Nasiri',1378)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (9,'Khadijeh','Afrooznia',1384)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (7,'Mina','Afrooznia',1385)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (6,'Mohammad','Noroozi',1383)
GO
--بررسی حجم جدول
SP_SPACEUSED ClusteredTable
GO
--بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
--در یک فضای دیگر ایجاد شده استNonClustered ایندکس
SELECT 
	S.index_id,S.index_type_desc,
	S.index_depth,S.index_level,
	S.page_count ,S.record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('MyDB2017'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED') S
GO
--------------------------------------------------------------------
--آنالیز ایندکس
GO
USE MyDB2017
GO
/*
صحفات وابسته به جدول
های تخصیص یافته ، هر کدام از آنها به تفکیک شرح داده شودPage تعداد 
را جداگانه داریمClusteredTable , NonClustered توجه شود که در درخت وابسته به ایندکس 
*/
GO
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('ClusteredTable'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc
GO
/*
صحفات وابسته به جدول
را جداگانه داریمClusteredTable , NonClustered توجه شود که در درخت وابسته به ایندکس 
*/
SELECT 
	page_type_desc,allocated_page_page_id,
	next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('ClusteredTable'),
		NULL,NULL,'DETAILED'
	)
GO
