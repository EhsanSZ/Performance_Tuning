
--Filestream ایجاد یک بانک اطلاعاتی با پشتیبانی از ویژگی 
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
-------------------------------
--Filestream ایجاد بانک اطلاعاتی جدید به همراه فایل گروه 
USE master
GO
CREATE DATABASE MyDB2017
ON PRIMARY 
(
	NAME = MyDB2017,FILENAME = 'C:\Temp\MyDB2017.mdf'
),
FILEGROUP FG_FileStream CONTAINS FILESTREAM
(
	NAME = MyDB2017_FSG,FILENAME ='C:\Temp\MyDB2017_FSG'
)
LOG ON 
(
	NAME = MyDB2017_Log,FILENAME = 'C:\Temp\MyDB2017_Log.ldf'
)
GO
--NTFS مشاهده فایل ها در 
GO
--Object Explorer بررسی نحوه ایجاد بانک اطلاعاتی در 
GO
USE MyDB2017
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
-------------------------------
--فرض کنید بانک اطلاعاتی از قبل وجود دارد و قرار است ما 
--به آن اضافه کنیم Filestream
GO
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017
ON PRIMARY 
(
	NAME = MyDB2017,FILENAME = 'C:\Temp\MyDB2017.mdf'
)
LOG ON 
(
	NAME = MyDB2017_Log,FILENAME = 'C:\Temp\MyDB2017_Log.ldf'
)
GO
USE MyDB2017
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
--Filestream اضافه کردن فایل گروه از نوع
ALTER DATABASE MyDB2017 ADD 
	FILEGROUP FG_FileStream CONTAINS FILESTREAM
GO
ALTER DATABASE MyDB2017 ADD FILE
(
	NAME = MyDB2017_FSG,FILENAME ='C:\Temp\MyDB2017_FSG'
) TO FILEGROUP FG_FileStream
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
--Object Explorer بررسی در 
GO
