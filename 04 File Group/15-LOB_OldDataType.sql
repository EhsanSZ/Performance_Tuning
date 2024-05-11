
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
USE Test01
GO
DROP TABLE IF EXISTS TextData
GO
--ایجاد جدول
DROP TABLE IF EXISTS dbo.TextData
GO
CREATE TABLE dbo.TextData
(
    ID INT IDENTITY not null,
    Col1 TEXT null
)
GO
INSERT INTO dbo.TextData(Col1) VALUES 
	('HELLO1'),
	('HELLO2')
GO
INSERT INTO dbo.TextData( Col1) VALUES ( replicate('a',16000))
GO
SELECT * FROM TextData
GO
DBCC IND('Test01','TextData',-1) WITH NO_INFOMSGS;--همه ركوردها توجه iam_chanin_type به فيلد 
GO
--DBCC IND معادل 
SELECT 
	* 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('Test01'),OBJECT_ID('TextData'),
		NULL,NULL,'DETAILED'
	)
GO
--------------------------------------------------------------------
--به فایل گروه دیگرLOB انتقال داده های 
DROP TABLE IF EXISTS dbo.TextData
GO
CREATE TABLE dbo.TextData
(
    ID INT IDENTITY not null,
    Col1 TEXT null
)ON FG_Data TEXTIMAGE_ON FG_LOB
GO
INSERT INTO dbo.TextData(Col1) VALUES ('HELLO1')
GO 10000
--های تخصیص داده شده به هر کدام از فایل هاExtent بررسی وضعیت 
DBCC SHOWFILESTATS
GO
--بررسی وضعیت حجم هر کدام از فایل ها
SELECT 
	DB_NAME() AS [DatabaseName],
	 Name, file_id, 
	 physical_name,
	(size * 8.0/1024) as Size,
	((size * 8.0/1024) - (FILEPROPERTY(name, 'SpaceUsed') * 8.0/1024)) As FreeSpace
From sys.database_files
GO