
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
--مشاهده فایل های بانک اطلاعاتی 
SP_HELPFILE
SELECT FILE_ID,name,size,max_size,growth FROM sys.database_files
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
--SSMS نمایش فایل گروه در 
--------------------------------------------------------------------
--Primary FileGroup بررسی 
GO
USE Northwind
GO
--Primary FileGroup بررسی
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
--مشاهده اشیاء سیستمی
SELECT * FROM SYS.objects
SELECT * FROM SYS.sysobjects
GO
--مشاهده اشیاء سیستمی
--قرار دارند Primary File Group اشیاء سیستمی در 
SELECT * FROM SYS.objects S
	WHERE S.type_desc IN ('SYSTEM_TABLE','INTERNAL_TABLE','SERVICE_QUEUE')
GO
