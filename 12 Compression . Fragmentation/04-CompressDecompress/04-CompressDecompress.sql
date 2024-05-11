
USE master
GO
--ساخت بانک اطلاعاتی
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
--------------------------------------------------------------------
--Compress, DeCompress استفاده از تابع 
GO
USE MyDB2017
GO
SELECT COMPRESS(N'Hello World + www.NikAmooz.com + Masoud Taheri + Farid Taheri')
SELECT DECOMPRESS(0x1F8B0800000000000400F3604865C801C27C0605867020590464A700D9DA405C0E867A0C7E0C990CD90C8E0CB940F97C862AA0483290CE85AAF26548642806F24BC1FA4280BC0CA09945403D107937A00888872E0B0035695EBD7A000000)
SELECT CAST(DECOMPRESS(0x1F8B0800000000000400F3604865C801C27C0605867020590464A700D9DA405C0E867A0C7E0C990CD90C8E0CB940F97C862AA0483290CE85AAF26548642806F24BC1FA4280BC0CA09945403D107937A00888872E0B0035695EBD7A000000) AS NVARCHAR(MAX))
SELECT CAST(DECOMPRESS(0x1F8B0800000000000400F3604865C801C27C0605867020590464A700D9DA405C0E867A0C7E0C990CD90C8E0CB940F97C862AA0483290CE85AAF26548642806F24BC1FA4280BC0CA09945403D107937A00888872E0B0035695EBD7A000000) AS VARCHAR(MAX))
GO
--ایجاد جدول برای حالت غیر فشرده
USE MyDB2017
GO
DROP TABLE IF EXISTS Customers_WithoutCompress
GO
CREATE TABLE Customers_WithoutCompress
(
	ID INT IDENTITY NOT NULL,	
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100),
	Comments NVARCHAR(MAX)
)
GO
SET NOCOUNT ON
DECLARE @C INT=1
WHILE @C<=1000
BEGIN
	INSERT INTO Customers_WithoutCompress (FirstName,LastName,Comments)
		VALUES ('F1','F2',REPLICATE('MasoudThaeri+FaridTaheri'+CAST(@C AS VARCHAR(10)),100))
	SET @C+=1
END
GO
SELECT * FROM Customers_WithoutCompress
GO
SP_SPACEUSED Customers_WithoutCompress
GO
SELECT 
	allocation_unit_type_desc,page_type_desc, 
	count(*) as TotalPages 
FROM sys.dm_db_database_page_allocations 
	(
		DB_ID('MyDB2017'),
		OBJECT_ID('Customers_WithoutCompress'),
		0,1,'DETAILED'
	) 
GROUP BY allocation_unit_type_desc,page_type_desc 
ORDER BY allocation_unit_type_desc

--ایجاد جدول برای حالت  فشرده
USE MyDB2017
GO
DROP TABLE IF EXISTS Customers_Compress
GO
CREATE TABLE Customers_Compress
(
	ID INT IDENTITY NOT NULL,	
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100),
	Comments VARBINARY(MAX)
)
GO
SET NOCOUNT ON
DECLARE @C INT=1
WHILE @C<=1000
BEGIN
	INSERT INTO Customers_Compress (FirstName,LastName,Comments)
		VALUES ('F1','F2',COMPRESS(REPLICATE('MasoudThaeri+FaridTaheri'+CAST(@C AS VARCHAR(10)),100)))
	SET @C+=1
END
GO
SELECT * FROM Customers_Compress
GO
SP_SPACEUSED Customers_Compress
GO
SELECT 
	allocation_unit_type_desc,page_type_desc, 
	count(*) as TotalPages 
FROM sys.dm_db_database_page_allocations 
	(
		DB_ID('MyDB2017'),
		OBJECT_ID('Customers_Compress'),
		0,1,'DETAILED'
	) 
GROUP BY allocation_unit_type_desc,page_type_desc 
ORDER BY allocation_unit_type_desc
GO
SELECT 
	*,
	CAST(DECOMPRESS(Comments) AS VARCHAR(MAX)) AS Decompress_Comments  
FROM Customers_Compress
GO
--Show Actual Execution Plan
SET STATISTICS IO ON 
SELECT * FROM Customers_WithoutCompress
SELECT * FROM Customers_Compress
GO
/*
است Gzip الگوریتم مربوط به فشرده سازی 
امکن غیر فشرده کردن با دات نت فراهم می باشد
*/
/*
var rec = (from x in ctx.WithCompresses
             select x).FirstOrDefault();
MemoryStream ms = new MemoryStream(rec.longfield);
GZipStream gz = new GZipStream(ms, CompressionMode.Decompress);
StreamReader sr = new StreamReader(gz);
textBox2.Text = sr.ReadToEnd();
*/
SELECT top 1 Comments from Customers_Compress
GO
--------------------------------------------------------------------
/*
تمرین 
*/
--Filestream ایجاد یک بانک اطلاعاتی با پشتیبانی از ویژگی 
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
--NTFS مشاهده فایل ها در 
GO
--Object Explorer بررسی نحوه ایجاد بانک اطلاعاتی در 
GO
USE MyDB2017
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
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
DECLARE @B_Compress VARBINARY(MAX)
SELECT 
	@B_Compress=COMPRESS(BulkColumn)
FROM OPENROWSET
	(
		BULK N'C:\Temp\Spark in Action.pdf', 
		SINGLE_BLOB, Single_Blob
	) AS tmp
INSERT INTO TestTable(Title,Content) VALUES ('CompressData',@B_Compress)
GO
DECLARE @B_NonCompress VARBINARY(MAX)
SELECT 
	@B_NonCompress=BulkColumn
FROM OPENROWSET
	(
		BULK N'C:\Temp\Spark in Action.pdf', 
		SINGLE_BLOB, Single_Blob
	) AS tmp
INSERT INTO TestTable(Title,Content) VALUES ('NonCompressData',@B_NonCompress)
GO
SELECT 
	Title,
	DATALENGTH(Content) AS Size_Byte,
	DATALENGTH(Content)/1024.0/1024.0 AS Size_MB
FROM TestTable
GO
--درج یک تصویر در جدول
INSERT INTO TestTable(Title,Content)
	SELECT 
		'Performance Tuning', BulkColumn 
	FROM OPENROWSET
		(
			BULK N'C:\Temp\Image1.png', 
			SINGLE_BLOB, Single_Blob
		) AS tmp
GO

