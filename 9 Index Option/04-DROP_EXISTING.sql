
--DROP_EXISTINGبررسی استفاده از  
GO
USE master
GO
--ساخت بانک اطلاعاتی
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017
GO
--Simple به Recovery Model تغییر
ALTER DATABASE MyDB2017 SET RECOVERY SIMPLE
GO
USE MyDB2017
GO
--ایجاد یک جدول جدید
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	C1 INT IDENTITY ,
	C2 CHAR(4000),
	C3 DATETIME DEFAULT GETDATE()
)
GO
--درج تعدادی رکورد در جدول
INSERT TestTable(C2) VALUES (N'T1')
GO 100
--مشاهده حجم رکوردهای موجود در جدول
SP_SPACEUSED TestTable
GO
--------------------------------------------------------------------
--ساخت ایندکس کلاستر به صورت عادی
GO
CHECKPOINT
GO
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
GO
--Clustered Index ایجد یک 
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON TestTable(C1)
GO
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
/*
ساخت ایندکس کلاستر به صورت عادی
nb_records:183	kbytes:19
*/
GO
CHECKPOINT
GO
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
GO
-----------------------------------
--DROP_EXISTING ساخت ایندکس کلاستر به صورت 
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON TestTable(C1)
	WITH (DROP_EXISTING=ON)
GO
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
/*
DROP_EXISTING ساخت ایندکس کلاستر به صورت 
nb_records:157	kbytes:17
*/
GO
CHECKPOINT
GO
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
GO
-----------------------------------
--بازسازی ایندکس
GO
ALTER INDEX IX_Clustered ON TestTable REBUILD
GO
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
/*
بازسازی ایندکس
nb_records:142	kbytes:16
*/
GO
--------------------------------------------------------------------
--مقایسه هر کدام از روش های مورد استفاده 
GO
/*
ساخت ایندکس کلاستر به صورت عادی
nb_records:183	kbytes:19
*/
GO
/*
DROP_EXISTING ساخت ایندکس کلاستر به صورت 
nb_records:157	kbytes:17
*/
GO
/*
بازسازی ایندکس
nb_records:142	kbytes:16
*/