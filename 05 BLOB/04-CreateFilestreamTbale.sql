
--مروری بر برخی از حالت ها 
--GUID ,...
USE MyDB2017
GO
--ایجاد جدول اول
DROP TABLE IF EXISTS TestTable1 
GO
CREATE TABLE TestTable1
(
	GuidCol UNIQUEIDENTIFIER DEFAULT NEWID(),
	ID  INT IDENTITY(1,1),
	TestData VARCHAR(60) 
)
GO
INSERT INTO TestTable1 (TestData) VALUES 
	('Ehsan Seyedzadeh'),
	('Amir Kharazi'),
	('Ali Seyedzadeh'),
	('Hamid Rahnama')
GO
--GUID تصادفی بودن مقادیر
SELECT * FROM TestTable1
GO
------------------------------
--ایجاد جدول دوم
DROP TABLE IF EXISTS TestTable2 
GO
CREATE TABLE TestTable2
(
	GuidCol UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID(),
	ID  INT IDENTITY(1,1),
	TestData VARCHAR(60) 
)
GO
INSERT INTO TestTable2 (TestData) VALUES 
	('Ehsan Seyedzadeh'),
	('Amir Kharazi'),
	('Ali Taheri'),
	('Alireza Taheri')
GO
--GUID تصادفی بودن مقادیر
SELECT * FROM TestTable2
SELECT * FROM TestTable1
GO
------------------------------
--ایجاد جدول سوم
DROP TABLE IF EXISTS TestTable3 
GO
CREATE TABLE TestTable3
(
	GuidCol UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() ROWGUIDCOL,
	ID  INT IDENTITY(1,1),
	TestData VARCHAR(60) 
)
GO
GO
INSERT INTO TestTable3 (TestData) VALUES 
	('Ehsan Seyedzadeh'),
	('Amir Kharazi'),
	('Ali Seyedzadeh'),
	('Hamid Rahnama')
GO
SELECT 
	$ROWGUID,$IDENTITY ,IdentityCol, 
	GuidCol,ID,TestData
FROM TestTable3
GO
DROP TABLE IF EXISTS TestTable1
DROP TABLE IF EXISTS TestTable2
DROP TABLE IF EXISTS TestTable3
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
--NTFS بررسی فایل های موجود در 
GO
--Object Explorer بررسی در 
GO
------------------------------
--به جدولی که از قبل وجود داردFilestream اضافه کردن قابلیت 
USE MyDB2017
GO
DROP TABLE IF EXISTS TestTable
GO
--ایجاد جدول
CREATE TABLE TestTable
(
	ID INT	IDENTITY PRIMARY KEY,
	Title	NVARCHAR(255) NOT NULL
)    
GO
ALTER TABLE TestTable SET(FILESTREAM_ON ='FG_FileStream')
GO
ALTER TABLE TestTable ADD
	FileID  UNIQUEIDENTIFIER NOT NULL ROWGUIDCOL UNIQUE DEFAULT(NEWID()),
	Content	VARBINARY(MAX) FILESTREAM NULL
GO	
--بررسی فایل گروه جدول
SP_HELP TestTable
GO
--بررسی ایندکس های جدول
SP_HELPINDEX TestTable
GO	 
------------------------------
--است Filestream درج رکورد در جدولی که دارای 
USE MyDB2017
GO
INSERT INTO TestTable(Title,Content)
	VALUES ('Ehsan Seyedzadeh',CAST(REPLICATE('Ehsan Seyedzadeh*',10) AS VARBINARY(MAX)))
GO
SELECT * FROM TestTable
GO
SELECT *,CAST(Content AS VARCHAR(MAX)) FROM TestTable
GO
--NTFS مشاهده فایل در
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
SELECT * FROM TestTable
GO
SELECT *,CAST(Content AS VARCHAR(MAX)) FROM TestTable
GO
SELECT ID,FILEID,Title,Content.PathName() FROM TestTable
GO
