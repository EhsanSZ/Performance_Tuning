
--VARBINARY(MAX) تست برای 
--EXEC sp_tableoption 'LOB_Table', 'large value types out of row', 1;
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
--دیتا لارج آبجکت در فایل گروه جداگانه ذخیره می شود
EXEC sp_tableoption 'LOB_Table', 'large value types out of row', 1;
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
	VALUES ('FirstName','LastName',CAST(REPLICATE('HELLO',1) AS NVARCHAR(MAX)))
GO
SELECT sys.fn_PhysLocFormatter (%%physloc%%) AS [Physical RID], * FROM LOB_Table;
GO
SELECT 
	* 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('Test01'),OBJECT_ID('LOB_Table'),
		NULL,NULL,'DETAILED'
	)
GO

