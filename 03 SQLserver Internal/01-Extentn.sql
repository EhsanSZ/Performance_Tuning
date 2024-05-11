
--ساخت بانک اطلاعاتی برای بررسی فایل های مربوط به آن
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
-------------------------------
Use MyDB2017
GO
--ایجاد جدول تستی
DROP TABLE IF EXISTS TestTable 
GO
CREATE TABLE TestTable 
(
	RecordID BIGINT PRIMARY KEY,
	RecordData VARCHAR(8000)
)
GO
--درج تعدادی رکورد تستی در جدول 
INSERT INTO TestTable (RecordID,RecordData) VALUES 
	(6,'Row6'),
	(3,'Row3'),
	(2,'Row2'),
	(8,'Row8'),
	(4,'Row4'),
	(9,'Row9'),
	(7,'Row7'),
	(1,'Row1'),
	(5,'Row5')
GO
--مشاهده رکوردهای درج شده
SELECT * FROM TestTable
GO
-------------------------------
--های تخصیص داده شده به جدولPage مشاهده 
--همه ركوردها توجه iam_chanin_type به فيلد 
DBCC IND('MyDB2017','TestTable',-1) WITH NO_INFOMSGS;
GO
SELECT 
	COUNT(database_id) AS PageCount_TB_FixedLength
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestTable'),
		NULL,NULL,'DETAILED'
	)
GO
SELECT 
	allocated_page_page_id,
	page_type_desc,
	allocated_page_iam_page_id,
	extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestTable'),
		NULL,NULL,'DETAILED'
	)
GO
-------------------------------
/*
 است Uniform Extent از نسخه 2016 به بعد به صورت SQL Server رفتار
 است Trace Flag 1118 این حالت معادل 
ALTER DATABASE MyDB2017 SET MIXED_PAGE_ALLOCATION OFF
GO
DBCC TRACEON(1118)
GO
*/
-------------------------------
--Mixed Page استفاده از حالت 
ALTER DATABASE MyDB2017 SET MIXED_PAGE_ALLOCATION ON;
GO
--ایجاد جدول تستی
DROP TABLE IF EXISTS TestTable1 
DROP TABLE IF EXISTS TestTable2
GO
CREATE TABLE TestTable1 
(
	RecordID BIGINT PRIMARY KEY,
	RecordData CHAR(8000)
)
GO
CREATE TABLE TestTable2
(
	RecordID BIGINT PRIMARY KEY,
	RecordData CHAR(8000)
)
GO
--درج تعدادی رکورد تستی در جدول 
INSERT INTO TestTable1 (RecordID,RecordData) VALUES 
	(6,'Row6'),
	(3,'Row3'),
	(2,'Row2')
GO
--درج تعدادی رکورد تستی در جدول 
INSERT INTO TestTable2 (RecordID,RecordData) VALUES 
	(7,'Row7'),
	(1,'Row1'),
	(5,'Row5')
GO
--مشاهده رکوردهای درج شده
SELECT * FROM TestTable1
SELECT * FROM TestTable2
GO
-------------------------------
--های تخصیص داده شده به جدولPage مشاهده 
SELECT 
	allocated_page_page_id,
	page_type_desc,
	allocated_page_iam_page_id,
	extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestTable1'),
		NULL,NULL,'DETAILED'
	)
GO
SELECT 
	allocated_page_page_id,
	page_type_desc,
	allocated_page_iam_page_id,
	extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestTable2'),
		NULL,NULL,'DETAILED'
	)
GO
--این رفتار دقیقا در نسخه های پایین تر از 2016 وجود دارد
GO
-------------------------------
--است Uniform Extent بررسی اینکه کدام بانک  های اطلاعاتی ما 
SELECT name,is_mixed_page_allocation_on FROM SYS.DATABASES
GO
