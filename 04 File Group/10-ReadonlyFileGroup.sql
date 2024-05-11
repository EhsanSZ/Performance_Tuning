
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
		NAME=Data,FILENAME='D:\Database\Data.ndf'
	)
	,
	FILEGROUP FG_ReadOnlyData
	(
		NAME=ReadOnlyData,FILENAME='D:\Database\ReadOnlyData.ndf'
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
IF OBJECT_ID('Test_Table')>0
	DROP TABLE Test_Table
GO
--ایجاد جدول
CREATE TABLE Test_Table
(
	ID INT IDENTITY PRIMARY KEY,
	Info1 CHAR(7000) DEFAULT 'Test_Table'
) ON FG_Data
GO
--بررسی فایل گروه جدول
SP_HELP Test_Table
GO
INSERT INTO Test_Table DEFAULT VALUES
GO 1000
--بررسی جهت وجود جدول
IF OBJECT_ID('ReadOlny_Table')>0
	DROP TABLE ReadOlny_Table
GO
--ایجاد جدول
CREATE TABLE ReadOlny_Table
(
	ID INT IDENTITY PRIMARY KEY,
	Info1 CHAR(7000) DEFAULT 'ReadOlny_Table'
) ON FG_ReadOnlyData
GO
--بررسی فایل گروه جدول
SP_HELP ReadOlny_Table
GO
INSERT INTO ReadOlny_Table DEFAULT VALUES
GO 1000
--بررسی حجم دو جدول
EXEC SP_SPACEUSED Test_Table
EXEC SP_SPACEUSED ReadOlny_Table
GO
--کردن فایل گروه مورد نظرRead-Only
ALTER DATABASE Test01 MODIFY FILEGROUP FG_ReadOnlyData READONLY WITH ROLLBACK IMMEDIATE
GO
