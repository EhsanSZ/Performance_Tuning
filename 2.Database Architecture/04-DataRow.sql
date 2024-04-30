
--SQL SERVER ها در Data Type بررسی 
USE Northwind
GO
--مشاهده دیتا تایپ ها به ازای جداول
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
GO
--مشاهده دیتا تایپ های غیر مجاز
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE DATA_TYPE IN('TEXT','NTEXT','IMAGE')
GO
--از هر دیتا تایپ چند تا داریم
SELECT 
	Data_Type,
	COUNT(*) AS CountDataType 
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY Data_Type
ORDER BY Data_Type
GO
--------------------------------------------------------------------
USE TempDB
GO
--Maximum allowable table row size of 8060 bytes
--برای هر رکورد 7 بایت فضای اضافی در نظر گرفته می شود
GO
DROP TABLE IF EXISTS Maxsize_Table
GO
--پيغام مربوط به دستور ايجاد جدول بررسي شود
CREATE TABLE Maxsize_Table
(
	F1 CHAR(8000) NOT NULL,
	F2 CHAR(60) NOT NULL
)
GO
DROP TABLE IF EXISTS Maxsize_Table
GO
--(8053+7)
--پيغام مربوط به دستور ايجاد جدول بررسي شود
CREATE TABLE Maxsize_Table
(
	F1 CHAR(8000) NOT NULL,
	F2 CHAR(53) NOT NULL
)
GO
--------------------------------------------------------------------
--Variable Length و Fixed Lenghتفاوت نوع داده 
USE master
GO
--بررسی وجود بانک اطلاعاتی
IF DB_ID('TestDB')>0
BEGIN
	ALTER DATABASE TestDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE TestDB
END
GO
--ایجاد بانک اطلاعاتی جدید
CREATE DATABASE TestDB
GO
--------------------------------------------------------------------
Use TestDB
GO
DROP TABLE IF EXISTS TB_FixedLength
DROP TABLE IF EXISTS TB_VariableLength
GO
--ایجاد جدول 1
CREATE TABLE TB_FixedLength
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName CHAR(12),
)
GO
--ایجاد جدول 2
CREATE TABLE TB_VariableLength
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName VARCHAR(12) ,
)
GO
--------------------------------------------------------------------
--TB_FixedLength,TB_VariableLength درج رکوردهای تستی در جدول 
SET NOCOUNT ON
GO
DECLARE @C INT =1
WHILE @C<=10000
BEGIN 
	INSERT INTO TB_FixedLength (FirstName) VALUES('abcdef') --Len=6 * DataLength=12
	INSERT INTO TB_VariableLength (FirstName) VALUES('abcdefghijkl') --Len=12 * DataLength=12
	SET @C+=1
END
--فضای حداکثر را به خود تخصیص می دهد Fixed Length نوع داده 
--------------------------------------------------------------------
--مشاهده دیتاهای درج شده
SELECT * FROM TB_FixedLength
GO
SELECT * FROM TB_VariableLength
GO
--------------------------------------------------------------------
--مشاهده ظرفیت تخصیص داده شده به جدول
SP_SPACEUSED TB_FixedLength
GO
SP_SPACEUSED TB_VariableLength
GO
--------------------------------------------------------------------
--های تخصیص داده شده به جدولPage مشاهده 
SELECT 
	COUNT(database_id) AS PageCount_TB_FixedLength
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('TestDB'),OBJECT_ID('TB_FixedLength'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
SELECT 
	COUNT(database_id) AS PageCount_TB_VariableLength
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('TestDB'),OBJECT_ID('TB_VariableLength'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
--------------------------------------------------------------------
--IO مشاهده وضعیت
SELECT * FROM TB_FixedLength
GO
SELECT * FROM TB_VariableLength
GO
--------------------------------------------------------------------
--Fixed Length , Variable Length هنگام کار با دیتا تایپ های NULL رفتار 
DROP TABLE IF EXISTS TB_FixedLength
DROP TABLE IF EXISTS TB_VariableLength
GO
--ایجاد جدول 1
CREATE TABLE TB_FixedLength
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName CHAR(12),
)
GO
--ایجاد جدول 2
CREATE TABLE TB_VariableLength
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName VARCHAR(12) ,
)
GO
--TB_FixedLength,TB_VariableLength درج رکوردهای تستی در جدول 
SET NOCOUNT ON
GO
DECLARE @C INT =1
WHILE @C<=10000
BEGIN 
	INSERT INTO TB_FixedLength (FirstName) VALUES(NULL) 
	INSERT INTO TB_VariableLength (FirstName) VALUES(NULL) 
	SET @C+=1
END
GO
--مشاهده رکوردهای درج شده
SELECT * FROM TB_FixedLength
SELECT * FROM TB_VariableLength
GO
--های تخصیص داده شده به جدولPage مشاهده 
SELECT 
	COUNT(database_id) AS PageCount_TB_FixedLength
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('TestDB'),OBJECT_ID('TB_FixedLength'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
SELECT 
	COUNT(database_id) AS PageCount_TB_VariableLength
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('TestDB'),OBJECT_ID('TB_VariableLength'),
		NULL,NULL,'DETAILED'
	)
WHERE page_type_desc='DATA_PAGE'
GO
/*
باشند Null فضای حداکثری را به خود تخصیص می دهند حتی اگر Fixed Length نوع داده های
Fixed Length : Int,SmallInt,DateTime,Char,NChar,...

 را دارد Overhead صفر باید فضا دارد اما فضای Null هنگام ذخیره مقدار  Variable Length نوع داده های 
*/
--------------------------------------------------------------------
--Data Row بررسی 
USE master
GO
--بررسي جهت وجود بانك اطلاعاتي و حذف آن
IF DB_ID('PageAnatomy')>0
BEGIN
	ALTER DATABASE PageAnatomy SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE PageAnatomy
END
GO	
--ايجاد بانك اطلاعاتي
CREATE DATABASE PageAnatomy
GO
USE PageAnatomy
GO
--------------------------------------------------------------------
CREATE TABLE DataRows
(
	ID INT NOT NULL,
	Col1 VARCHAR(255) null,
	Col2 VARCHAR(255) null,
	Col3 VARCHAR(255) null
);
INSERT INTO DataRows(ID, Col1, Col3) VALUES (1,REPLICATE('a',255),REPLICATE('c',255));
INSERT INTO  DataRows(ID, Col2) VALUES (2,REPLICATE('b',255));
GO
SELECT * FROM DataRows
GO
--های وابسته به یک جدولPage بدست آوردن 
DBCC IND('PageAnatomy','DataRows',-1) WITH NO_INFOMSGS;--همه ركوردها توجه iam_chanin_type به فيلد 
GO
DBCC TRACEON(3604)
DBCC PAGE
(
	'PageAnatomy'/*Database Name*/
	,1  /*File ID*/
	,294/*Page ID*/
	,3 /*Output mode: 3 - display page header and row details */
);
--DataRow1 مراجعه به عکس

--byte-swapped 