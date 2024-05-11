
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
USE MyDB2017
GO
--ساخت جدول تستی
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	ID INT,
	FullName NVARCHAR(30)
)
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON TestTable(ID)
GO
--مشاهده ایندکس هی مربوط به جدول
SP_HELPINDEX TestTable
GO
INSERT INTO TestTable VALUES (1,N'مسعود طاهری')
INSERT INTO TestTable VALUES (2,N'فرید طاهری')
INSERT INTO TestTable VALUES (2,N'علی طاهری')
INSERT INTO TestTable VALUES (3,N'علیرضا طاهری')
GO
SELECT * FROM TestTable
GO
----------------------------------
/*
IGNORE_DUP_KEYاستفاده از ویژگی 
*/
USE MyDB2017
GO
--ساخت جدول تستی
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	ID INT,
	FullName NVARCHAR(30)
)
GO
/*
دقت كنيدIGNORE_DUP_KEYبه تنظيم
هم به ازای IGNORE_DUP_KEY استفاده از ویژگی 
می باشد Clustered Index , NonClustered Index
*/
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON TestTable(ID)
	WITH (IGNORE_DUP_KEY = ON)
GO
--مشاهده ایندکس هی مربوط به جدول
SP_HELPINDEX TestTable
GO
INSERT INTO TestTable VALUES (1,N'مسعود طاهری')
INSERT INTO TestTable VALUES (2,N'فرید طاهری')
INSERT INTO TestTable VALUES (2,N'علی طاهری')
INSERT INTO TestTable VALUES (3,N'علیرضا طاهری')
GO
--به هشدار ايجاد شده دقت كنيد
SELECT * FROM TestTable
GO
INSERT INTO TestTable VALUES (2,N'علی طاهری')
SELECT * FROM TestTable
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
/*
BulkInsert بررسی سناریو
*/
USE MyDB2017
GO
--ساخت جدول تستی
DROP TABLE IF EXISTS Doctor1
GO
CREATE TABLE Doctor1
(
	DoctorCode INT,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100),
	DoctorGroupCode INT
)
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON Doctor1(DoctorCode)
GO
SELECT * FROM Doctor1
GO
--TSQL با استفاده از دستورات Bulk درج دیتا به صورت 
BULK INSERT Doctor1 
FROM N'C:\Temp\Doctor_Data.csv'
WITH  
( 
	CODEPAGE = '65001',  
    DATAFILETYPE = 'char',  
    FIELDTERMINATOR = '	' ,
	FirstRow=2
);  
GO
SELECT * FROM Doctor1
----------------------------------
/*
IGNORE_DUP_KEYاستفاده از ویژگی 
*/
USE MyDB2017
GO
--ساخت جدول تستی
DROP TABLE IF EXISTS Doctor2
GO
CREATE TABLE Doctor2
(
	DoctorCode INT,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100),
	DoctorGroupCode INT
)
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON Doctor2(DoctorCode)
	WITH (IGNORE_DUP_KEY = ON)
GO
SELECT * FROM Doctor2
GO
--TSQL با استفاده از دستورات Bulk درج دیتا به صورت 
BULK INSERT Doctor2 
FROM N'C:\Temp\Doctor_Data.csv'
WITH  
( 
	CODEPAGE = '65001',  
    DATAFILETYPE = 'char',  
    FIELDTERMINATOR = '	' ,
	FirstRow=2
);  
GO
SELECT * FROM Doctor2
GO