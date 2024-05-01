
--برای تنظیم اندازه لاگ فایل Best Practice بررسی یک 
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
--64MB ساخت بانک اطلاعاتی با اندازه پیش فرض و تنظیم رشد
CREATE DATABASE MyDB2017
 ON  PRIMARY 
( 
	NAME = N'MyDB2017',
	FILENAME = N'C:\Temp\MyDB2017.mdf' ,
	SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB 
)
LOG ON 
( 
	NAME = N'MyDB2017_log',
	FILENAME = N'C:\Temp\MyDB2017_log.ldf' ,
	SIZE = 8192KB , MAXSIZE = 2048GB, FILEGROWTH = 65536KB 
)
GO
USE MyDB2017
GO
--بررسی اندازه فایل ها و نحوه رشد آنها
SP_HELPFILE
GO
--ها VLF مشاهده تعداد
-- 4=ها در هنگام ایجاد VLF تعداد 
SELECT 
	* 
FROM sys.dm_db_log_info(DEFAULT)
GO
--ساخت جداول بزرگ برای افزایش حجم بانک اطلاعاتی
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	C1 INT IDENTITY PRIMARY KEY,
	C2 CHAR(4000),
	C3 CHAR(4000)
)
GO
--ها کنترل شودVLF حدود 7 الی 8 بار اجرا و هر بار تعداد 
INSERT TestTable(C2,C3) VALUES (NULL,NULL)
GO 1000
--ها VLF مشاهده تعداد
SELECT 
	* 
FROM sys.dm_db_log_info(DEFAULT)
GO
/*
< 64MB there will be 4 new VLFs (each 1/4 of growth size)
64MB to 1GB there will be 8 new VLFs (each 1/8 of growth size)
> 1GB there will be 16 new VLFs (each 1/16 of growth size)
*/

/*
لاگ فایل پیش فرض تنظیم شده سیستم Initial Size , File Growth چون 
می شود و این موضوع باعث بوجود آمدن مشکل VLF مجبور به ساخت 
 می شود  Log Fragmentation
راه حل رفع مشکل در ادامه
*/
/*
This is important to be considered as too many VLFs can lead to:

Long recovery time when SQL is starting up
Long time for a restore of a database to complete
Attaching a database runs too slow
Timeout errors when trying to create a new mirroring session
*/

USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
--ساخت بانک اطلاعاتی و تنظیم اعداد مناسب برای لاگ فایل 
CREATE DATABASE MyDB2017
 ON  PRIMARY 
( 
	NAME = N'MyDB2017',
	FILENAME = N'C:\Temp\MyDB2017.mdf' ,
	SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB 
)
LOG ON 
( 
	NAME = N'MyDB2017_log',
	FILENAME = N'C:\Temp\MyDB2017_log.ldf' ,
	SIZE = 1GB , MAXSIZE = 2048GB, FILEGROWTH = 1GB 
)
GO
--Full Backup شروع زنجیره لاگ با اولین 
BACKUP DATABASE MyDB2017 TO DISK='C:\Temp\MyDB2017_Full.bak' WITH FORMAT
GO
USE MyDB2017
GO
--بررسی اندازه فایل ها و نحوه رشد آنها
SP_HELPFILE
GO
--ها VLF مشاهده تعداد
-- 8=ها در هنگام ایجاد VLF تعداد 
SELECT 
	* 
FROM sys.dm_db_log_info(DEFAULT)
GO
--ساخت جداول بزرگ برای افزایش حجم بانک اطلاعاتی
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	C1 INT IDENTITY PRIMARY KEY,
	C2 CHAR(4000),
	C3 CHAR(4000)
)
GO
--ها کنترل شودVLF حدود 7 الی 8 بار اجرا و هر بار تعداد 
INSERT TestTable(C2,C3) VALUES (NULL,NULL)
GO 100000
--ها VLF مشاهده تعداد
SELECT 
	* 
FROM sys.dm_db_log_info(DEFAULT)
GO
/*
< 64MB there will be 4 new VLFs (each 1/4 of growth size)
64MB to 1GB there will be 8 new VLFs (each 1/8 of growth size)
> 1GB there will be 16 new VLFs (each 1/16 of growth size)
*/


