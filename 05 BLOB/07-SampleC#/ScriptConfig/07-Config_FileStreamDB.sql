
USE master
GO
--SQL Server در سطح سرویسFilestream اعمال تنظیمات مربوط به 
GO
--Instance در سطحFilestream اعمال تنظیمات مربوط به 
--دستور
--SSMS
GO
USE master
GO
SP_CONFIGURE 'show advanced options',1
RECONFIGURE
GO
SP_CONFIGURE 'filestream access level',2  -- 0:Disable , 1:Transact SQL Access , 2:Full Acess Enabled
RECONFIGURE
GO
--------------------------------------------------------------------
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی و حذف آن
IF DB_ID('FileStreamTestDB')>0
	DROP DATABASE FileStreamTestDB
GO
--FileStream ایجاد یک بانک اطلاعاتی جدید به همراه قابلیت
CREATE DATABASE FileStreamTestDB
ON PRIMARY 
(
	NAME = FileStreamTestDB,FILENAME = 'D:\Database\FileStreamTestDB.mdf'
),
FILEGROUP FG_FileStream CONTAINS FILESTREAM
(
	NAME = FileStreamTestDB_FSG,FILENAME ='D:\Database\FileStreamTestDB_FSG'
)
LOG ON 
(
	NAME = FileStreamTestDB_Log,FILENAME = 'D:\Database\FileStreamTestDB_Log.ldf'
)
GO
USE FileStreamTestDB
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT name,type_desc,physical_name FROM sys.database_files
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
------------------------------------------------------------------------------
--Filestream ایجاد جدول شامل 
USE FileStreamTestDB
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('BLOB_Table')>0
	DROP TABLE BLOB_Table
GO
--ایجاد جدول
CREATE TABLE BLOB_Table
(
	PkId INT PRIMARY KEY IDENTITY (1, 1),
	FileID UNIQUEIDENTIFIER NOT NULL UNIQUE ROWGUIDCOL DEFAULT NEWSEQUENTIALID(),
	Comments NVARCHAR(200) NOT NULL,
	FName NVARCHAR(200) NOT NULL,
	FileData VARBINARY(MAX) FILESTREAM NULL
) ON [PRIMARY] FILESTREAM_ON FG_FileStream
GO
------------------------------------------------------------------------------
SP_HELP BLOB_Table
GO
------------------------------------------------------------------------------
SELECT * FROM BLOB_Table
GO
TRUNCATE TABLE BLOB_Table



SELECT PkId,FILEID,Comments,FName,FileData.PathName() FROM BLOB_Table
GO
BEGIN TRANSACTION
SELECT 
	Comments,FName,FileData.PathName() AS FilePath,
	GET_FILESTREAM_TRANSACTION_CONTEXT()  AS ServerTxn  
FROM BLOB_Table WHERE PKID=1
GO
--این مقاله در خصوص افزایش کارایی فایل استریم تکنیک های مناسبی را مشخص کرده است 

https://technet.microsoft.com/en-us/library/cc645923(v=sql.110).aspx