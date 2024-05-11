
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی و حذف آن
IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE Test01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test01
END
GO
CREATE DATABASE Test01 
	ON  PRIMARY
	(
		NAME=Test01_Primary,FILENAME='D:\Database\Test01_Primary.mdf'
	),
	FILEGROUP FG_Data
	(
		NAME=Data1,FILENAME='D:\Database\Data1.ndf'
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
--مشاهده اشیاء سیستمی
--قرار دارند Primary File Group اشیاء سیستمی در 
SELECT * FROM SYS.objects S
	WHERE S.type_desc IN ('SYSTEM_TABLE','INTERNAL_TABLE','SERVICE_QUEUE')
GO
--قرار ندهیدPrimary FileGroup جداول خود را در 

--بررسی جهت وجود جدول
IF OBJECT_ID('Test_Table')>0
	DROP TABLE Test_Table
GO
--ایجاد جدول
CREATE TABLE Test_Table
(
	ID INT PRIMARY KEY,
	Info1 CHAR(7000) DEFAULT 'Test_Table',
	Info2 CHAR(500)
) ON FG_Data
GO
--بررسی فایل گروه جدول
SP_HELP Test_Table
GO
