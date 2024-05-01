
--Bulk Logged Recovery Model بررسی 
/*
Full Recovery Model بخش اول مثال حجم یک کار را در حالت 
نمایش می دهد
*/
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
	C1 INT IDENTITY PRIMARY KEY,
	C2 CHAR(4000)
)
GO
--درج حجم نسبتا زیادی رکورد در جدول 
INSERT TestTable(C2) VALUES (N'T1')
GO 20000
--مشاهده حجم رکوردهای موجود در جدول
SP_SPACEUSED TestTable
GO
CHECKPOINT
GO
DBCC SHRINKFILE(MyDB2017_log,10)
GO
CHECKPOINT
GO
--Full به Recovery Model تغییر
ALTER DATABASE MyDB2017 SET RECOVERY FULL
BACKUP DATABASE MyDB2017 TO DISK ='C:\TEMP\MyDB2017_Full.bak' WITH FORMAT,COMPRESSION
GO
--بررسی حجم لاگ فایل
SELECT COUNT(*) FROM fn_dblog(NULL,NULL)
GO
--بازسازی ایندکس ها
ALTER INDEX ALL ON TestTable REBUILD
GO
--بررسی حجم لاگ فایل
SELECT COUNT(*) FROM fn_dblog(NULL,NULL)
GO

