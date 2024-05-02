
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
		NAME=MyDB2017_Data1,FILENAME='C:\Temp\MyDB2017_Data1.ndf'
	),
	(
		NAME=MyDB2017_Data2,FILENAME='C:\Temp\MyDB2017_Data2.ndf'
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
--ایجاد فایل گروه جدید
ALTER DATABASE MyDB2017 ADD FILEGROUP FG2
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
--اضافه کردن دیتا فایل به فایل گروه جدید
ALTER DATABASE MyDB2017 ADD FILE
(
		NAME=MyDB2017_Data3,FILENAME='C:\Temp\MyDB2017_Data3.ndf'
) TO FILEGROUP FG2
GO
ALTER DATABASE MyDB2017 ADD FILE
(
		NAME=MyDB2017_Data4,FILENAME='C:\Temp\MyDB2017_Data4.ndf'
) TO FILEGROUP FG2
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
--عوض شدن نام فایل گروه 
ALTER DATABASE MyDB2017 MODIFY FILEGROUP FG2  NAME=FG2_new
GO