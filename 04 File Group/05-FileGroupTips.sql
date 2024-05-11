
--ساخت بانک اطلاعاتی برای بررسی فایل های مربوط به آن
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
--ایجاد بانک اطلاعاتی موجود در اسلاید
CREATE DATABASE MyDB2017 
	ON  PRIMARY
	(
		NAME=MyDB2017,FILENAME='C:\Temp\MyDB2017.mdf'
	),
	FILEGROUP FG1
	(
		NAME=MyDB2017_Data1,FILENAME='C:\Temp\MyDB2017_Data1.ndf',SIZE=1MB,FILEGROWTH=1MB
	),
	(
		NAME=MyDB2017_Data2,FILENAME='C:\Temp\MyDB2017_Data2.ndf',SIZE=1MB,FILEGROWTH=1MB
	),
	FILEGROUP FG2
	(
		NAME=MyDB2017_Data3,FILENAME='C:\Temp\MyDB2017_Data3.ndf',SIZE=1MB,FILEGROWTH=1MB
	),
	(
		NAME=MyDB2017_Data4,FILENAME='C:\Temp\MyDB2017_Data4.ndf',SIZE=1MB,FILEGROWTH=1MB
	)
	LOG ON
	(
		NAME=MyDB2017_log,FILENAME='C:\Temp\MyDB2017_log.ldf'
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
USE MyDB2017
GO
--ها FileGroup بررسی وضعیت رشد دیتا فایل های مربوط به هر  
SELECT 
	name,is_autogrow_all_files 
FROM SYS.filegroups
GO
--Uniform Extent بررسی وضعیت 
SELECT 
	name,is_mixed_page_allocation_on 
FROM SYS.DATABASES 
	WHERE name='MyDB2017'
GO
/*
ALTER DATABASE MyDB2017 SET MIXED_PAGE_ALLOCATION OFF;
GO
*/
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
--FG1 ایجاد جدول در فایل گروه 
DROP TABLE IF EXISTS Students1
GO
CREATE TABLE Students1
(
	ID INT IDENTITY PRIMARY KEY,
	FullName CHAR(4000)
) ON FG1
GO
--بررسی مشخصات مربوط به جدول
SP_HELP Students1
GO
INSERT INTO Students1(FullName) VALUES ('www.NikAmooz.com')
GO 1000
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
USE master
GO
--تنظیم رشد یکسان دیتا فایل های مربوط به هر فایل گروه
ALTER DATABASE MyDB2017 MODIFY FILEGROUP FG2 AUTOGROW_ALL_FILES
GO
--ها FileGroup بررسی وضعیت رشد دیتا فایل های مربوط به هر  
SELECT 
	name,is_autogrow_all_files 
FROM SYS.filegroups
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
--FG2 ایجاد جدول در فایل گروه 
DROP TABLE IF EXISTS Students2 
GO
CREATE TABLE Students2
(
	ID INT IDENTITY PRIMARY KEY,
	FullName CHAR(4000)
) ON FG2
GO
--بررسی مشخصات مربوط به جدول
SP_HELP Students2
GO
INSERT INTO Students2 (FullName) VALUES ('www.Ehsansz.ir')
GO 1000
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
