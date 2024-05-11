
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
GO
USE MyDB2017
GO
-------------------------------
--مشاهده فایل های بانک اطلاعاتی
SP_HELPFILE
GO
SELECT * FROM sys.database_files
GO
--تنظیم ظرفیت فایل های بانک اطلاعاتی
SELECT 
	name,
	type_desc,
	physical_name,
	CAST((size*8.0/1024) AS DECIMAL(18,2))AS Size_MB,
	max_size
FROM SYS.database_files
GO
-------------------------------
--مشاهده فایل های بانک اطلاعاتی
SP_HELPFILE
GO
SELECT * FROM sys.database_files
GO
-------------------------------
--ایجاد یک بانک اطلاعاتی ساده
--به پارمترهای مربوط به بانک اطلاعاتی توجه کنید
GO
USE master
GO
IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE Test01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test01
END
GO
CREATE DATABASE Test01
	ON
	(
		NAME=Test01,FILENAME='E:\Database\Test01.mdf',
		SIZE=5GB,MAXSIZE=UNLIMITED,FILEGROWTH=1024MB
	)
	LOG ON
	(
		NAME=TEST01_log,FILENAME='E:\Database\Test01_log.LDF',
		SIZE=1GB,MAXSIZE=5GB,FILEGROWTH=1024MB
	)
GO
USE Test01
GO
--مشاهده فایل های بانک اطلاعاتی
SP_HELPFILE
GO
SELECT 
	FILE_ID,name,physical_name,size,max_size,growth 
FROM sys.database_files
GO
-------------------------------
--ایجاد یک بانک اطلاعاتی به همراه چند دیتا فایل و لاگ فایل
GO
USE master
GO
IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE Test01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test01
END
GO
--ساخت یک بانک اطلاعاتی با چند دیتا فایل
CREATE DATABASE Test01
	ON
	(
		NAME=Test01_DATA1,FILENAME='E:\Database\TEST01_DATA1.mdf',
		SIZE=10MB,MAXSIZE=10GB,FILEGROWTH=10%
	),
	(
		NAME=Test01_DATA2,FILENAME='E:\Database\TEST01_DATA2.ndf',
		SIZE=10MB,MAXSIZE=10GB,FILEGROWTH=10%
	),
	(
		NAME=Test01_DATA3,FILENAME='E:\Database\TEST01_DATA3.ndf',
		SIZE=10MB,MAXSIZE=10GB,FILEGROWTH=10%
	)
	LOG ON
	(
		NAME=TEST01_log1,FILENAME='E:\Database\TEST01_log1.LDF',
		SIZE=100MB,MAXSIZE=15GB,FILEGROWTH=10%
	),
	(
		NAME=TEST01_log2,FILENAME='E:\Database\TEST01_log2.LDF',
		SIZE=100MB,MAXSIZE=15GB,FILEGROWTH=10%
	)
GO
USE Test01
GO
--مشاهده فایل های بانک اطلاعاتی
SP_HELPFILE
GO
SELECT 
	FILE_ID,name,physical_name,size,max_size,growth 
FROM sys.database_files
GO
ALTER DATABASE Test01 MODIFY FILE(NAME='Test01_DATA1',NEWNAME='Test01_DATA1_X')
GO
