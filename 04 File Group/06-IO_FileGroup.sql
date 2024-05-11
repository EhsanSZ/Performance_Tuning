
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
	ON  PRIMARY
	(
		NAME=MyDB2017,FILENAME='C:\Temp\MyDB2017.mdf'
	),
	FILEGROUP FG_Stock
	(
		NAME=Data_Stock,FILENAME='C:\Temp\Data_Stock.ndf'
	),
	FILEGROUP FG_ACC
	(
		NAME=Data_ACC,FILENAME='C:\Temp\Data_ACC.ndf'
	)
	LOG ON
	(
		NAME=MyDB2017_log1,FILENAME='C:\Temp\MyDB2017_log.LDF'
	)
GO
USE MyDB2017
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--سوال : اندازه و نحوه رشد این بانک اطلاعاتی بر چه اساسی ایجاد شده است
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
--------------------------------------------------------------------
--ایجاد جدول
DROP TABLE IF EXISTS Stock_Table
GO
CREATE TABLE Stock_Table
(
	ID INT IDENTITY PRIMARY KEY,
	Info CHAR(8000)
) 
GO
--بررسی ساختار جدول و فایل گروه مربوط به آن 
SP_HELP Stock_Table
GO
--فلسفه فایل گروه پیش فرض
GO
/*
CREATE TABLE Stock_Table
(
	ID INT IDENTITY PRIMARY KEY,
	Info CHAR(8000) DEFAULT 'TEST_Stock_Table'
) ON FG_Stock
GO
*/
--ایجاد جدول
CREATE TABLE ACC_Table
(
	ID INT IDENTITY PRIMARY KEY,
	Info CHAR(8000) DEFAULT 'TEST_ACC_Table'
) ON FG_ACC
GO