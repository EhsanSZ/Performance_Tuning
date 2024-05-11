
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی و حذف آن
IF DB_ID('Test01')>0
	DROP DATABASE Test01
GO
CREATE DATABASE Test01 
	ON  PRIMARY
	(
		NAME=Test01_Primary,FILENAME='D:\Database\Test01_Primary.mdf'
	),
	FILEGROUP FG_Data
	(
		NAME=Data1,FILENAME='D:\Database\Data1.ndf'
	),
	FILEGROUP FG_Index
	(
		NAME=Index1,FILENAME='D:\Database\Index1.ndf'
	),
	FILEGROUP FG_LOB
	(
		NAME=Data_LOB,FILENAME='D:\Database\Data_LOB.ndf'
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
--------------------------------------------------------------------
--NVARCHAR(MAX),VARCHAR(MAX),XML,TEXT,NTEXT تست برای 
--بررسی جهت وجود جدول
IF OBJECT_ID('LOB_Table')>0
	DROP TABLE LOB_Table
GO
--ایجاد جدول
CREATE TABLE LOB_Table
(
	ID INT IDENTITY PRIMARY KEY,
	FirstName CHAR(1000) DEFAULT 'FirstName',
	LastName CHAR(1000) DEFAULT 'LastName',
	LobField NVARCHAR(MAX)
) ON FG_Data TEXTIMAGE_ON FG_LOB
GO
--بررسی فایل گروه جدول
SP_HELP LOB_Table
GO
--مشاهده ظرفیت مربوط به دیتا فایل ها
SELECT * FROM sys.database_files
GO
SP_HELPFILE
GO
INSERT INTO LOB_Table(FirstName,LastName,LobField) 
	VALUES ('FirstName','LastName',CAST(REPLICATE('HELLO',1000) AS NVARCHAR(MAX)))
GO 10000
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--مشاهده صفحات تخصیص داده شده به جدول
SELECT 
	* 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('Test01'),OBJECT_ID('LOB_Table'),
		NULL,NULL,'DETAILED'
	)
GO
SELECT 
	page_type_desc,
	COUNT(*) AS RecCount 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('Test01'),OBJECT_ID('LOB_Table'),
		NULL,NULL,'DETAILED'
	)	
GROUP BY 
	page_type_desc
GO
