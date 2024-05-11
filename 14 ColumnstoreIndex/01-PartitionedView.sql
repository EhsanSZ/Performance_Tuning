
USE master
GO
IF DB_ID('DB1')>0
BEGIN
	ALTER DATABASE DB1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DB1
END
GO
IF DB_ID('DB2')>0
BEGIN
	ALTER DATABASE DB2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DB2
END
GO
IF DB_ID('DB3')>0
BEGIN
	ALTER DATABASE DB3 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DB3
END
GO
CREATE DATABASE DB1
CREATE DATABASE DB2
CREATE DATABASE DB3
GO
--------------------------------------------------------------------
USE master
GO
--ساخت جدول پرسنل برای سرور اول با شرط ورود كارمندانی كه دارای كد پرسنلی خاص هستند
CREATE TABLE DB1.dbo.Employees 
(
	EmployeeID INT PRIMARY KEY CHECK (EmployeeID BETWEEN 1 AND 100),
	FirtName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
--ساخت جدول پرسنل برای سرور دوم با شرط ورود كارمندانی كه دارای كد پرسنلی خاص هستند
CREATE TABLE DB2.dbo.Employees 
(
	EmployeeID INT PRIMARY KEY CHECK (EmployeeID BETWEEN 101 AND 200),
	FirtName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
--ساخت جدول پرسنل برای سرور سوم با شرط ورود كارمندانی كه دارای كد پرسنلی خاص هستند
CREATE TABLE DB3.dbo.Employees 
(
	EmployeeID INT PRIMARY KEY CHECK (EmployeeID BETWEEN 201 AND 300),
	FirtName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
--------------------------------------------------------------------
--DB1 درج دیتا در 
INSERT INTO DB1.dbo.Employees VALUES (1,N'مسعود',N'طاهری')
INSERT INTO DB1.dbo.Employees VALUES (2,N'فرید',N'طاهری')
INSERT INTO DB1.dbo.Employees VALUES (3,N'مجید',N'طاهری')
INSERT INTO DB1.dbo.Employees VALUES (4,N'علی',N'طاهری')
INSERT INTO DB1.dbo.Employees VALUES (120,N'علیرضا',N'طاهری')--شرط را چك كنید
GO
--DB2 درج دیتا در 
INSERT INTO DB2.dbo.Employees VALUES (120,N'علیرضا',N'طاهری')
INSERT INTO DB2.dbo.Employees VALUES (121,N'سامان',N'حسینی')
INSERT INTO DB2.dbo.Employees VALUES (122,N'محمد',N'نوری')
INSERT INTO DB2.dbo.Employees VALUES (123,N'بهرام',N'غفاری')
INSERT INTO DB2.dbo.Employees VALUES (250,N'علی',N'بسطامی')--شرط را چك كنید
GO
--DB3 درج دیتا در 
INSERT INTO DB3.dbo.Employees VALUES (250,N'علی',N'بسطامی')
INSERT INTO DB3.dbo.Employees VALUES (251,N'نادر',N'بیرونی')
INSERT INTO DB3.dbo.Employees VALUES (252,N'كریم',N'مقدادی')
INSERT INTO DB3.dbo.Employees VALUES (253,N'محمد',N'عطایی')
GO
--بررسی داده های موجود در جداول
SELECT EmployeeID,FirtName,LastName FROM DB1.dbo.Employees
SELECT EmployeeID,FirtName,LastName FROM DB2.dbo.Employees
SELECT EmployeeID,FirtName,LastName FROM DB3.dbo.Employees
GO
/*
Union ساخت یک کوئری با 
Execution Plan نمایش 
*/
SELECT EmployeeID,FirtName,LastName FROM DB1.dbo.Employees
UNION
SELECT EmployeeID,FirtName,LastName FROM DB2.dbo.Employees
UNION
SELECT EmployeeID,FirtName,LastName FROM DB3.dbo.Employees
GO
--------------------------------------------------------------------
--DB1 ایجاد یک ویو پارتیشن شده در 
USE DB1
GO
--Union استفاده از 
CREATE OR ALTER VIEW View_AllEmployees1
AS
	SELECT EmployeeID,FirtName,LastName FROM DB1.dbo.Employees
	UNION
	SELECT EmployeeID,FirtName,LastName FROM DB2.dbo.Employees
	UNION
	SELECT EmployeeID,FirtName,LastName FROM DB3.dbo.Employees
GO
--Union All استفاده از 
CREATE OR ALTER VIEW View_AllEmployees2
AS
	SELECT EmployeeID,FirtName,LastName FROM DB1.dbo.Employees
	UNION ALL
	SELECT EmployeeID,FirtName,LastName FROM DB2.dbo.Employees
	UNION ALL
	SELECT EmployeeID,FirtName,LastName FROM DB3.dbo.Employees
GO
/*
اجرای کوئری 
Execution Plan بررسی 
*/
SELECT * FROM View_AllEmployees1
SELECT * FROM View_AllEmployees2 
GO
SELECT * FROM View_AllEmployees1 WHERE EmployeeID BETWEEN 1 AND 50
SELECT * FROM View_AllEmployees2 WHERE EmployeeID BETWEEN 1 AND 50
GO
SELECT * FROM View_AllEmployees1 WHERE EmployeeID BETWEEN 1 AND 200
SELECT * FROM View_AllEmployees2 WHERE EmployeeID BETWEEN 1 AND 200
GO
GO
--پاک کردن همه دیتابیس ها
USE master
GO
DROP DATABASE IF EXISTS DB1
DROP DATABASE IF EXISTS DB2
DROP DATABASE IF EXISTS DB3
GO
