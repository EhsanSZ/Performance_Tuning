
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
--بررسی وجود جدول
DROP TABLE IF EXISTS ClusteredTable
GO
--Clustered ایجاد یک جدول از نوع
CREATE TABLE ClusteredTable
(
	ID CHAR(900),
	FirstName CHAR(3000),
	LastName CHAR(3000)
)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable 
GO
--درج تعدادی رکورد تستی
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (1,'Masoud','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (5,'Alireza','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (3,'Ali','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (4,'Majid','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (2,'Farid','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (10,'Ahmad','Ghafari')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (8,'Alireza','Nasiri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (9,'Khadijeh','Afrooznia')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (7,'Mina','Afrooznia')
INSERT INTO ClusteredTable(ID,FirstName,LastName) values (6,'Mohammad','Noroozi')
GO
-- مشاهده داده های موجود در جدول 
SELECT * FROM ClusteredTable
GO
CREATE CLUSTERED INDEX IX_Clustered ON ClusteredTable(ID)
GO
--------------------------------------------------------------------
/*
بررسی صفحات تخصیص داده شده به ایندکس
ها Index Page بررسی 
*/
--صحفات وابسته به جدول
SELECT 
	page_type_desc,allocated_page_page_id,
	next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('ClusteredTable'),
		NULL,NULL,'DETAILED'
	)
GO
--------------------------------------------------------------------
/*
DMF آنالیز ایندکس با استفاده از 
مشاهده وضعیت فیزیکی ایندکس 

sys.dm_db_index_physical_stats
 (
	  { database_id| NULL | 0 | DEFAULT }
	, { object_id| NULL | 0 | DEFAULT }
	, { index_id| NULL | 0 | -1 | DEFAULT }
	, { partition_number| NULL | 0 | DEFAULT }
	, { mode| NULL | DEFAULT } = (DEFAULT,LIMITED,SAMPLED,DETAILED ** DEFAULT=LIMITED)
)

1: LIMITED : Leaf Level

2: SAMPLED :Leaf Level & نمونه برداری از تعدادی از صفحات
--با توجه به اینکه نمونه برداری انجام می شود احتمال تقریبی بودن نتایج وجود دارد
If the number of leaf level pages is < 10000, read all the pages,
 otherwise read every 100th pages (i.e. a 1% sample)

3: DETAILED: نمایش تمامی سطوح برگ و غیر برگ
*/
--شکل کلی استفاده از ایندکس 
SELECT 
	*
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('ClusteredTable'),
	NULL,
	NULL,
	'DETAILED'
)
GO
--آنالیز ایندکس
SELECT 
	index_type_desc,index_depth,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('ClusteredTable'),
	1,
	NULL,
	'LIMITED'
)
GO
--------------------------------------------------------------------
/*
Procedure  آنالیز ایندکس با استفاده از 
*/
USE AdventureWorks2017
GO
SP_HELPINDEX 'Sales.SalesOrderDetail'
GO
--------------------------------------------------------------------
--DMF آنالیز ایندکس جدولی نسبتا بزرگ با 
GO
SELECT 
	*
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('Sales.SalesOrderDetail'),
	NULL,
	NULL,
	'DETAILED'
)
GO
--مشاهده یک ایندکس خاص
SELECT 
	*
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('Sales.SalesOrderDetail'),
	1,
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
	OBJECT_ID('Sales.SalesOrderDetail'),
	1,
	NULL,
	'DETAILED'
)
GO
