
--Filetable بررسی نحوه کار با 
GO
USE master
GO
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO
--ایجاد دایرکتوری محل ذخیره اطلاعات 
EXEC xp_cmdshell 'IF NOT EXIST C:\DemoFileTable MKDIR C:\DemoFileTable';
GO
--------------------------------------------------------------------
USE master
GO
IF DB_ID('DemoFileTable')>0
BEGIN
	ALTER DATABASE DemoFileTable SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DemoFileTable
END
GO
CREATE DATABASE DemoFileTable
WITH FILESTREAM
( 
	NON_TRANSACTED_ACCESS = FULL,
	DIRECTORY_NAME = N'FileTableDirectory'
)
GO
--اضافه کردن یک فایل گروه از نوع فایل استریم 
ALTER DATABASE DemoFileTable ADD FILEGROUP DemoFileTable_FG CONTAINS FILESTREAM;
GO
--به بانک اطلاعاتی  Filestream Container اضافه کردن
ALTER DATABASE DemoFileTable
ADD FILE
(
	NAME= 'DemoFileTable_File',
	FILENAME = 'C:\DemoFileTable\DemoFileTable_File'
) TO FILEGROUP DemoFileTable_FG;
GO
--------------------------------------------------------------------
USE DemoFileTable;
GO
/* Create a FileTable ایجاد جدول*/
CREATE TABLE DemoFileTable AS FILETABLE
WITH
( 
	FILETABLE_DIRECTORY = 'Dir4DemoFileTable',
	FILETABLE_COLLATE_FILENAME = database_default
);
GO
Use DemoFileTable;
GO
SELECT * FROM DemoFileTable;
GO
--Object Explorer بررسی در 
INSERT INTO dbo.DemoFileTable(Stream_ID,name, file_stream)
	VALUES('AB5B3FB3-3603-E411-BE93-0CD2925C26C7','InsertedTextFile1.txt', 0x);
GO
SELECT * FROM DemoFileTable WHERE Stream_ID='AB5B3FB3-3603-E411-BE93-0CD2925C26C7'
GO
--------------------------------------------------------------------
--دسترسی به مسیرها
USE DemoFileTable
GO
SELECT 
	file_stream.GetFileNamespacePath()
	--* 
FROM DemoFileTable;
GO
SELECT FileTableRootPath('dbo.DemoFileTable') as RootPath
GO
--------------------------------------------------------------------
USE DemoFileTable
GO
DROP TABLE IF EXISTS TestRelation1
GO
--FileTable ایجاد ارتباط با 
CREATE TABLE TestRelation1
(
	ID INT ,
	Stream_ID UNIQUEIDENTIFIER,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100),
	Comments NVARCHAR(100),
	CONSTRAINT PK_TestRelation1 PRIMARY KEY (ID),
	CONSTRAINT FK_TestRelation1_DemoFileTable FOREIGN KEY (Stream_ID)
		REFERENCES DemoFileTable(Stream_id)
)
GO
SP_HELP TestRelation1
GO
INSERT INTO TestRelation1(ID,Stream_ID,FirstName,LastName,Comments)
	VALUES (1,'AB5B3FB3-3603-E411-BE93-0CD2925C26C7',N'مسعود',N'طاهری',N'کلاس آموزشی')
GO
SELECT * FROM TestRelation1
GO
SELECT * FROM DemoFileTable;
GO
DELETE FROM DemoFileTable WHERE stream_id='AB5B3FB3-3603-E411-BE93-0CD2925C26C7'
GO
DROP TABLE TestRelation1
GO
--------------------------------------------------------------------
--بررسی روش برنامه نویسی
--کافی است یوزر ویندوزی به شاخه مورد نظر دسترسی داشته باشد
GO
