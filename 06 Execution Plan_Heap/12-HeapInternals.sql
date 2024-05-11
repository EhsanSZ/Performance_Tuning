
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
IF OBJECT_ID('HeapTable')>0
	DROP TABLE HeapTable
GO
--Heap ایجاد یک جدول از نوع
CREATE TABLE HeapTable
(
	ID INT,
	FirstName CHAR(3000),
	LastName CHAR(3000)
)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX HeapTable
GO
--Heap مشاهده جدول
--DMV
SELECT OBJECT_NAME(object_id),*  FROM sys.indexes
	WHERE index_id=0
GO
--View
SELECT * FROM SYS.sysindexes
	WHERE id=OBJECT_ID('HeapTable')
/*
به ستون های زیر توجه کنید
rows
FisrtIAM
*/
SELECT id,rows,FirstIAM FROM SYS.sysindexes
	WHERE id=OBJECT_ID('HeapTable')
GO
--درج یک رکورد تستی
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (1,'Masoud','Taheri')
SELECT * FROM HeapTable
GO
/*
به ستون های زیر توجه کنید
rows
FisrtIAM
*/
SELECT id,rows,FirstIAM FROM SYS.sysindexes
	WHERE id=OBJECT_ID('HeapTable')
GO
--درج تعدادی رکورد تستی
INSERT INTO HeapTable(ID,FirstName,LastName) values (3,'Farid','Taheri')
INSERT INTO HeapTable(ID,FirstName,LastName) values (2,'Ali','Taheri')
INSERT INTO HeapTable(ID,FirstName,LastName) values (5,'Majid','Taheri')
INSERT INTO HeapTable(ID,FirstName,LastName) values (4,'Alireza','Taheri')
SELECT * FROM HeapTable
GO
/*
به ستون های زیر توجه کنید
rows
FisrtIAM
*/
SELECT id,rows,FirstIAM FROM SYS.sysindexes
	WHERE id=OBJECT_ID('HeapTable')
GO
--بررسی صفحات جدول
DBCC IND('MyDB2017','HeapTable',1) WITH NO_INFOMSGS
GO
/*
IAM کلیه آدرس صفحات در 
عدم وجود ارتباط مابین صفحات
*/
SELECT 
	*
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('HeapTable'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
/*
 --هستند Heap تخمین اندازه جداولی که از نوع
Estimate the Size of a Heap
http://technet.microsoft.com/en-us/library/ms189124.aspx
*/


