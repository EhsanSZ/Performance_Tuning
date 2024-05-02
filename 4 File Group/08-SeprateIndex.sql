
--ساخت بانک اطلاعاتی
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
	FILEGROUP FG_Index
	(
		NAME=Data_Index,FILENAME='C:\Temp\Data_Index.ndf'
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
--ایجاد جدول
CREATE TABLE Stock_Table
(
	ID INT PRIMARY KEY,
	Info1 CHAR(7000) DEFAULT 'Stock_Table_Test',
	Info2 CHAR(500)
) ON FG_Stock
GO
--بررسی فایل گروه جدول
SP_HELP Stock_Table
GO
--ایجاد جدول
CREATE NONCLUSTERED INDEX IX01 ON 
	Stock_Table (Info2) ON FG_Index
GO
--بررسی ایندکس های جدول
SP_HELPINDEX Stock_Table
GO
--بررسی شودSSMS انجام اینکار در 
GO
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
--درج داده های تستی در جدول
DECLARE @X INT=1
WHILE @X<=10000
BEGIN
	INSERT INTO Stock_Table(ID,Info2) VALUES (@X,'TEST'+CAST(@X AS varchar(10)))
	SET @X+=1
END
GO
SELECT * FROM Stock_Table
GO
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
--------------------------------------------------------------------
--انتقال کلیه ایندکس ها به یک فایل گروه جداگانه
--بررسی جهت وجود جدول
IF OBJECT_ID('Stock_Table2')>0
	DROP TABLE Stock_Table2
GO
--ایجاد جدول
CREATE TABLE Stock_Table2
(
	ID INT PRIMARY KEY,
	Info1 CHAR(7000) DEFAULT 'Stock_Table_Test',
	Info2 CHAR(500)
) ON FG_Stock
GO
--ایجاد جدول
CREATE NONCLUSTERED INDEX IX01 ON 
	Stock_Table2 (Info2) 
GO
--بررسی ایندکس های جدول
SP_HELPINDEX Stock_Table2
GO
--به این اسکریپت دقت کنید
CREATE NONCLUSTERED INDEX IX01 ON Stock_Table (Info2) 
	WITH (DROP_EXISTING=ON) ON FG_Index 
GO
--بررسی ایندکس های جدول
SP_HELPINDEX Stock_Table
GO
