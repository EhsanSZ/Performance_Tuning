

USE master
GO
--بررسی جهت وجود بانک اطلاعاتی و حذف آن
IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE TEST01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test01
END
GO
--ایجاد بانک اطلاعاتی موجود در اسلاید
CREATE DATABASE Test01 
	ON  PRIMARY
	(
		NAME=Test01_Primary,FILENAME='D:\Database\Test01_Primary.mdf'
	),
	FILEGROUP FG_Stock
	(
		NAME=Data_Stock,FILENAME='D:\Database\Data_Stock.ndf'
	),
	FILEGROUP FG_ACC
	(
		NAME=Data_ACC,FILENAME='D:\Database\Data_ACC.ndf'
	)
	LOG ON
	(
		NAME=TEST01_log1,FILENAME='D:\Database\TEST01_log1.LDF'
	)
GO
USE Test01
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('Stock_Table')>0
	DROP TABLE Stock_Table
GO
--ایجاد جدول
CREATE TABLE Stock_Table
(
	ID INT IDENTITY PRIMARY KEY,
	Info CHAR(8000) DEFAULT 'TEST_Stock_Table'
) ON FG_Stock
GO
--بررسی فایل گروه جدول
SP_HELP Stock_Table
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('ACC_Table')>0
	DROP TABLE ACC_Table
GO
--ایجاد جدول
CREATE TABLE ACC_Table
(
	ID INT IDENTITY PRIMARY KEY,
	Info CHAR(8000) DEFAULT 'TEST_ACC_Table'
) ON FG_ACC
GO
--بررسی فایل گروه جدول
SP_HELP ACC_Table
GO
--بررسی شودSSMS انجام اینکار در 
GO
--بررسی ظرفیت فایل های بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
INSERT INTO Stock_Table DEFAULT VALUES
GO 1000
INSERT INTO ACC_Table DEFAULT VALUES
GO 1000
--بررسی ظرفیت فایل های بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--به حجم و مدت زمان تهیه نسخه پشتیبان توجه کنید

--Full Backup تهیه نسخه پشتیبان از نوع 
BACKUP DATABASE TEST01 
	TO  DISK = 'C:\TEMP\TEST01_FULL.bak' WITH STATS=1,FORMAT
GO
--FileGroup Backup تهیه نسخه پشتیبان از نوع 
BACKUP DATABASE TEST01 FILEGROUP = N'FG_Stock' 
	TO  DISK = 'C:\TEMP\TEST01_FG_Stock.bak' WITH STATS=1
GO
