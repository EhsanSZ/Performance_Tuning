
--ساخت بانک اطلاعاتی برای بررسی فایل های مربوط به آن
USE master
GO
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
--VarBinary(max) بررسی کوتاه 
USE MyDB2017
GO
DECLARE @V1 VARBINARY(MAX)=NULL
SELECT @V1
GO
DECLARE @V2 VARBINARY(MAX)=''
SELECT @V2
GO
DECLARE @V3 VARBINARY(MAX)=0X
SELECT @V3
GO
DECLARE @V4 VARBINARY(MAX)=CAST('Ehsan Seyedzadeh' AS VARBINARY(MAX))
SELECT @V4
GO
DECLARE @V5 VARBINARY(MAX)=CAST(N'Ehsan Seyedzadeh' AS VARBINARY(MAX))
SELECT @V5
GO
--خواندن یک فایل به صورت باینری
--OpenRowSet استفاده از تابع 
SELECT * FROM OPENROWSET
(
    BULK N'C:\Temp\Image1.png', SINGLE_BLOB
) Tbl
GO
--------------------------------------------------------------------
Use MyDB2017
GO
--درون دیتابیسBLOB ایجاد یک جدول برای ذخیره 
DROP TABLE IF EXISTS Employees1
GO
CREATE TABLE Employees1
(
	EmployeeID INT PRIMARY KEY,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100),
	Pic VARBINARY(MAX)
)
GO
INSERT INTO Employees1 (EmployeeID,FirstName,LastName,Pic) VALUES 
	(1,'Masoud','Taheri',0x),
	(2,'Farid','Taheri',NULL)
GO
SELECT * FROM Employees1
GO
--OpenRowSet ذخیره یک تصویر در دیتابیس با استفاده از تابع
INSERT INTO Employees1 (EmployeeID,FirstName,LastName,Pic)  
	SELECT 
		3,'Ali','Seyedzadeh',* 
	FROM OPENROWSET
	(
		BULK N'C:\Temp\Image1.png', SINGLE_BLOB
	) Tbl
GO 
SELECT * FROM Employees1
GO
--------------------------------------------------------------------
--درون دیتابیسBLOB ایجاد یک جدول برای ذخیره مسیر  
Use MyDB2017
GO
DROP TABLE IF EXISTS Employees2
GO
CREATE TABLE Employees2
(
	EmployeeID INT PRIMARY KEY,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100),
	Pic NVARCHAR(200)
)
GO
INSERT INTO Employees2(EmployeeID,FirstName,LastName,Pic) VALUES 
	(1,'Ehsan','Seyedzadeh',0x),
	(2,'Amir','Kharazi',NULL),
	(3,'Ali','Seyedzadeh','C:\Temp\Image1.png')
GO
SELECT * FROM Employees2
GO
--------------------------------------------------------------------
--مقایسه دو جدول
GO
--مقایسه حجم هر دو جدول
EXEC SP_SPACEUSED Employees1
EXEC SP_SPACEUSED Employees2
GO
--IO تعداد عملیات 
SET STATISTICS IO ON
SELECT * FROM Employees1
SELECT * FROM Employees2
SET STATISTICS IO OFF
GO
--------------------------------
--های تخصیص داده شده به جداولPageمقایسه 
GO
--VarBinary(max) جدول اول 
SELECT 
	allocated_page_page_id,
	page_type_desc,
	allocated_page_iam_page_id,
	extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('Employees1'),
		NULL,NULL,'DETAILED'
	)
GO
--جدول دوم ذخیره مسیر در بانک اطلاعاتی
SELECT 
	allocated_page_page_id,
	page_type_desc,
	allocated_page_iam_page_id,
	extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('Employees2'),
		NULL,NULL,'DETAILED'
	)
GO
