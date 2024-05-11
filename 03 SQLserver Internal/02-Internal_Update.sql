
--Update بررسی عملکرد دستور 
GO
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
ALTER DATABASE MyDB2017 SET RECOVERY SIMPLE
GO
USE MyDB2017
GO
--------------------------------------------------------------------
/*
Update پیاده سازی سناریوهای مربوط به 
هستند Heap , Clustered جداول به صورت 
*/
--------------------------------------------------------------------
--Fixed Length سناریو 1 :ایجاد جدول با فیلدهای 
USE MyDB2017
GO
DROP TABLE IF EXISTS TestingUpdate1 
GO
--Heap ایجاد یک جدول از نوع 
CREATE TABLE TestingUpdate1 
(
	ID INT IDENTITY,
	SomeString CHAR(50)
)
GO
INSERT INTO TestingUpdate1 (SomeString) VALUES
	('One'),('Two'),('Three'),('Four'),('Five'),
	('Six'),('Seven'),('Eight'),('Nine')
GO
SELECT * FROM TestingUpdate1
GO
CHECKPOINT 
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate1'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--انجام می شود Page با توجه به وجود فضا عملیات به روز رسانی در همان 
UPDATE TestingUpdate1 SET SomeString = 'NotFour'
	WHERE ID = 4 -- one row
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate1'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--مشاهده لاگ ثبت شده به ازای این عملیات
--In Place Update
SELECT 
	Operation, Context, 
	AllocUnitName, [Transaction Name], 
	Description 
FROM fn_dblog(NULL, NULL) AS TranLog
GO
DROP TABLE IF EXISTS TestingUpdate1 
GO
--------------------------------------------------------------------
--Variable Length سناریو 2 :ایجاد جدول با فیلدهای 
USE MyDB2017
GO
DROP TABLE IF EXISTS TestingUpdate2 
GO
--Heap ایجاد یک جدول از نوع 
CREATE TABLE TestingUpdate2 
(
	ID INT IDENTITY,
	SomeString VARCHAR(50)
)
GO
INSERT INTO TestingUpdate2 (SomeString) VALUES
	('One'),('Two'),('Three'),('Four'),('Five'),
	('Six'),('Seven'),('Eight'),('Nine')
GO
SELECT * FROM TestingUpdate2
GO
CHECKPOINT 
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate2'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--انجام می شود Page با توجه به وجود فضا عملیات به روز رسانی در همان 
UPDATE TestingUpdate2 SET SomeString = 'NotFour'
	WHERE ID = 4 -- one row
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate2'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--مشاهده لاگ ثبت شده به ازای این عملیات
--In Place Update
SELECT 
	Operation, Context, 
	AllocUnitName, [Transaction Name], 
	Description 
FROM fn_dblog(NULL, NULL) AS TranLog
GO
DROP TABLE IF EXISTS TestingUpdate2 
GO
--------------------------------------------------------------------
--Fixed Length سناریو 3 :ایجاد جدول با فیلدهای 
USE MyDB2017
GO
DROP TABLE IF EXISTS TestingUpdate3 
GO
--Heap ایجاد یک جدول از نوع 
CREATE TABLE TestingUpdate3 
(
	ID INT IDENTITY,
	SomeString CHAR(50)
)
GO
--درج حجم زیادی رکورد در جدول
INSERT INTO TestingUpdate3 (SomeString)
	SELECT TOP (1000000) ' ' FROM msdb.sys.columns a 
		CROSS JOIN msdb.sys.columns b
GO
SELECT TOP 1000 * FROM TestingUpdate3
GO
CHECKPOINT 
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate3'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--انجام می شود Page با توجه به وجود فضا عملیات به روز رسانی در همان 
UPDATE TestingUpdate3 SET SomeString = 'Something'
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate3'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--مشاهده لاگ ثبت شده به ازای این عملیات
--In Place Update
SELECT 
	Operation, Context, 
	AllocUnitName, [Transaction Name], 
	Description 
FROM fn_dblog(NULL, NULL) AS TranLog
GO
DROP TABLE IF EXISTS TestingUpdate3
GO
--------------------------------------------------------------------
--Fixed Length سناریو 4 :ایجاد جدول با فیلدهای 
USE MyDB2017
GO
DROP TABLE IF EXISTS TestingUpdate4 
GO
--Clustered ایجاد یک جدول از نوع 
CREATE TABLE TestingUpdate4 
(
	ID INT IDENTITY,
	SomeString CHAR(50)
)
GO
--ایجاد یک ایندکس کلاستر بر روی جدول
CREATE CLUSTERED INDEX IX_ID ON TestingUpdate4 (ID)
GO
INSERT INTO TestingUpdate4 (SomeString) VALUES
	('One'),('Two'),('Three'),('Four'),('Five'),
	('Six'),('Seven'),('Eight'),('Nine')
GO
SELECT * FROM TestingUpdate4
GO
CHECKPOINT 
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate4'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--انجام می شود Page با توجه به وجود فضا عملیات به روز رسانی در همان 
UPDATE TestingUpdate4 SET SomeString = 'NotFour'
	WHERE ID = 4 -- one row
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate4'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--مشاهده لاگ ثبت شده به ازای این عملیات
--In Place Update
SELECT 
	Operation, Context, 
	AllocUnitName, [Transaction Name], 
	Description 
FROM fn_dblog(NULL, NULL) AS TranLog
GO
DROP TABLE IF EXISTS TestingUpdate4 
GO
--------------------------------------------------------------------
--Variable Length سناریو 5 :ایجاد جدول با فیلدهای 
USE MyDB2017
GO
DROP TABLE IF EXISTS TestingUpdate5 
GO
--Clustered ایجاد یک جدول از نوع 
CREATE TABLE TestingUpdate5 
(
	ID INT IDENTITY,
	SomeString VARCHAR(50)
)
GO
--ایجاد یک ایندکس کلاستر بر روی جدول
CREATE CLUSTERED INDEX IX_ID ON TestingUpdate5 (ID)
GO
INSERT INTO TestingUpdate5 (SomeString) VALUES
	('One'),('Two'),('Three'),('Four'),('Five'),
	('Six'),('Seven'),('Eight'),('Nine')
GO
SELECT * FROM TestingUpdate5
GO
CHECKPOINT 
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate5'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--انجام می شود Page با توجه به وجود فضا عملیات به روز رسانی در همان 
UPDATE TestingUpdate5 SET SomeString = 'NotFour'
	WHERE ID = 4 -- one row
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate5'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--مشاهده لاگ ثبت شده به ازای این عملیات
--In Place Update
SELECT 
	Operation, Context, 
	AllocUnitName, [Transaction Name], 
	Description 
FROM fn_dblog(NULL, NULL) AS TranLog
GO
DROP TABLE IF EXISTS TestingUpdate5 
GO
--------------------------------------------------------------------
--Fixed Length سناریو 6 :ایجاد جدول با فیلدهای 
USE MyDB2017
GO
DROP TABLE IF EXISTS TestingUpdate6 
GO
--Clustered ایجاد یک جدول از نوع 
CREATE TABLE TestingUpdate6 
(
	ID INT ,
	SomeString CHAR(50)
)
GO
--ایجاد یک ایندکس کلاستر بر روی جدول
CREATE CLUSTERED INDEX IX_ID ON TestingUpdate6 (ID)
GO
INSERT INTO TestingUpdate6 (ID,SomeString) VALUES
	(1,'One'),(2,'Two'),(3,'Three'),(4,'Four'),(5,'Five'),
	(6,'Six'),(7,'Seven'),(8,'Eight'),(9,'Nine')
GO
SELECT * FROM TestingUpdate6
GO
CHECKPOINT 
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate6'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--به روز رسانی فیلد کلید ایندکس
UPDATE TestingUpdate6 SET SomeString = 'NotFour' ,ID=42
	WHERE ID = 4 -- one row
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate6'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--مشاهده لاگ ثبت شده به ازای این عملیات
/*
عملیات درج و حذف رخ داده است
LOP_DELETE_ROWS
*/
SELECT 
	Operation, Context, 
	AllocUnitName, [Transaction Name], 
	Description 
FROM fn_dblog(NULL, NULL) AS TranLog
GO
DROP TABLE IF EXISTS TestingUpdate6 
GO
--------------------------------------------------------------------
--Variable Length سناریو 7 :ایجاد جدول با فیلدهای 
USE MyDB2017
GO
DROP TABLE IF EXISTS TestingUpdate7 
GO
--Clustered ایجاد یک جدول از نوع 
CREATE TABLE TestingUpdate7 
(
	ID INT IDENTITY,
	SomeString VARCHAR(1000)
)
GO
--ایجاد یک ایندکس کلاستر بر روی جدول
CREATE CLUSTERED INDEX IX_ID ON TestingUpdate7 (ID)
GO
INSERT INTO TestingUpdate7 (SomeString) VALUES (REPLICATE('A',1000))
GO 14
GO
INSERT INTO TestingUpdate7 (SomeString) VALUES ('Masoud')
GO
SELECT * FROM TestingUpdate7
GO
CHECKPOINT 
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate7'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--به روز رسانی فیلد کلید ایندکس
UPDATE TestingUpdate7 SET SomeString = REPLICATE('A',1000)
	WHERE ID = 15 -- one row
GO
--های مربوط به جدولPage مشاهده تعداد 
SELECT 
	COUNT(*) AS Data_Page_Count 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestingUpdate7'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
--مشاهده لاگ ثبت شده به ازای این عملیات
/*
عملیات درج و حذف رخ داده است
LOP_DELETE_SPLIT
*/
SELECT 
	Operation, Context, 
	AllocUnitName, [Transaction Name], 
	Description 
FROM fn_dblog(NULL, NULL) AS TranLog
GO
DROP TABLE IF EXISTS TestingUpdate7 
GO
--------------------------------------------------------------------
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
