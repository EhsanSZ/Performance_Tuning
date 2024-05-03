
--Always-ON در Filestream استفاده از 
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
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
--------------------------------------------------------------------
--Filestream ایجاد یک جدول برای استفاده از ویژگی 
GO
USE MyDB2017
GO
--ایجاد فایل 
DROP TABLE IF EXISTS TestTable
GO
--ایجاد جدول
CREATE TABLE TestTable
(
	ID INT	IDENTITY PRIMARY KEY,
	FileID  UNIQUEIDENTIFIER NOT NULL ROWGUIDCOL UNIQUE DEFAULT(NEWSEQUENTIALID()),
	Title	NVARCHAR(255) NOT NULL,
	Content	VARBINARY(MAX) FILESTREAM NULL
)    
ON [PRIMARY] FILESTREAM_ON FG_FileStream
GO
--------------------------------------------------------------------
USE master
GO
BACKUP DATABASE MyDB2017 TO DISK='C:\Temp\MyDB2017_Full.bak'
	WITH COMPRESSION
GO
--------------------------------------------------------------------
USE MyDB2017
GO
INSERT INTO TestTable(Title,Content)
	VALUES ('Ehsan Seyedzadeh',CAST(REPLICATE('Ehsan Seyedzadeh*',10) AS VARBINARY(MAX)))
GO
--------------------------------------------------------------------
--Listener بررسی 
/*
:Connect Secondary
*/
USE master
GO
ALTER AVAILABILITY GROUP [EhssanAG] FAILOVER;
GO
