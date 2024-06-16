
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO
--------------------------------------------------------------------
/*
Simplificationبررسی مرحله 
حذف تضادهای موجود در کوئری ها
*/
USE MyDB2017
GO
--ایجاد جدول تستی
DROP TABLE IF EXISTS PositiveNumbers
CREATE TABLE dbo.PositiveNumbers
(
	PositiveNumber INT NOT NULL
	CONSTRAINT CHK_PositiveNumbers CHECK (PositiveNumber>0)
)
GO
--ایجاد جدول تستی
DROP TABLE IF EXISTS dbo.NegativeNumbers
CREATE TABLE dbo.NegativeNumbers
(
	NegativeNumber INT NOT NULL
	CONSTRAINT CHK_NegativeNumbers CHECK (NegativeNumber<0)
)
GO
/*
Simplification حذف تضادهای موجود در کوئری طی مرحله  
Execution نمایش 
*/
SELECT 
	*
FROM dbo.PositiveNumbers e INNER JOIN dbo.NegativeNumbers o ON
	e.PositiveNumber = o.NegativeNumber
GO
--------------------------------------------------------------------
/*
(پلن بدیهی) Trivial Plan Search بررسی مرحله
وجود یک پلن برای کوئری
*/
USE MyDB2017
GO
--ایجاد جدول تستی
DROP TABLE IF EXISTS dbo.TestData
CREATE TABLE dbo.TestData
(
	ID INT NOT NULL,
	Col1 INT NOT NULL,
	Col2 INT NOT NULL,
	CONSTRAINT PK_Data PRIMARY KEY CLUSTERED(ID)
)
GO
/*
Execution Plan مشاهده 
Optimization Level = TRIVIAL بررسی ویژگی 
*/
SELECT 
	ID, Col1, Col2 
FROM TestData 
WHERE ID = 11111
GO
--------------------------------------------------------------------
/*
Query Optimization مشاهده مراحل مربوط به 
DBCC TRACEON(3604)
OPTION (RECOMPILE, QUERYTRACEON 8675):Trace flag 8675 shows the query optimization phases 
*/
DBCC TRACEON(3604)
GO
USE Northwind
GO
SELECT 
	Orders.OrderID,
	Orders.OrderDate,
	Customers.CompanyName,
	CONCAT(Employees.FirstName ,' ',Employees.LastName) AS FullName,
	[Order Details].ProductID
FROM Orders 
INNER JOIN [Order Details] ON 
	[Order Details].OrderID=Orders.OrderID
INNER JOIN Customers ON 
	Orders.CustomerID=Customers.CustomerID
INNER JOIN Employees ON 
	Orders.EmployeeID=Employees.EmployeeID
WHERE Orders.OrderID IN (10250,10251)
OPTION (RECOMPILE, QUERYTRACEON 8675)
GO
--مشاهده اطلاعات مربوط به بهینه سازی
SELECT * FROM  sys.dm_exec_query_optimizer_info 
--مشاهده تعداد بهینه سازی های انجام شده
GO
SELECT 
	occurrence AS Optimizations 
FROM sys.dm_exec_query_optimizer_info  
WHERE counter = 'optimizations';  
GO
--مدت زمان سپری شده برای بهینه سازی کوئریها
SELECT 
	ISNULL(value,0.0) AS ElapsedTimePerOptimization  
FROM sys.dm_exec_query_optimizer_info WHERE counter = 'elapsed time'
GO

