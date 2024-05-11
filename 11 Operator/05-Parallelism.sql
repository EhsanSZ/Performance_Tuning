
/*
Parallelism

*/
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
-------------------------------------
USE MyDB2017
GO
--بررسی جهت وجود جدول و پاک کردن آن
DROP TABLE IF EXISTS ParallelDemo
GO
--ایجاد جدول تستی
CREATE TABLE ParallelDemo
( 
	ID INT IDENTITY (1,1) PRIMARY KEY,
	FirstName NVARCHAR (200),
	LastName NVARCHAR (200),
	PhoneNumber VARCHAR(50),
	BirthDate DATETIME,
	Address NVARCHAR(MAX)
)
GO
SET NOCOUNT ON 
--دج رکورد تستی در جدول
INSERT INTO ParallelDemo VALUES ('Masoud','Taheri','123456789','1982-01-01','www.NikAmmoz.com')
GO 50000 
INSERT INTO ParallelDemo VALUES ('Farid','Taheri','987654321','1983-01-01','www.NikAmmoz.com')
GO 50000
--بررسی تعداد رکوردهای درج شده	
SP_SPACEUSED ParallelDemo
GO
/*
Execution Plan , Time Statistics مشاهده 
Thread 0 بررسی  (Managment Thread)

*/
SET STATISTICS TIME ON
GO
--Parallel اجرای کوئری به صورت 
SELECT 
	ID
	,FirstName
	,LastName
	,PhoneNumber
	,BirthDate
	,Address
FROM dbo.ParallelDemo
WHERE 
	Address LIKE '%AMM%'
ORDER BY 
	BirthDate DESC
GO
--اجرای کوئری به صورت سریال
SELECT 
	ID
	,FirstName
	,LastName
	,PhoneNumber
	,BirthDate
	,Address
FROM dbo.ParallelDemo
WHERE 
	Address LIKE '%AMM%'
ORDER BY 
	BirthDate DESC
OPTION (MAXDOP 1)
GO
SP_WHO XX
GO
-------------------------------------
--max degree of parallelism بررسی 
/*
=0 : استفاده حداکثر
=1 : اجرای درخواست های به صورت سریال
>1 : ها به تعداد مشخص شدهCPU Core استفاده از 
*/
USE master
GO
SP_CONFIGURE 'max degree of parallelism',0
GO
-------------------------------------
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
GO
USE AdventureWorks2017
GO
SELECT 
	PP.[ProductID]
	,[Name]
	,[ProductNumber]
	,PTH.ActualCost 
	,PTH.TransactionType      
FROM [Production].[Product] PP
INNER JOIN [Production].TransactionHistory PTH
	ON PP.ProductID =PTH.ProductID 
WHERE 
	PP.SellEndDate <GETDATE()-2 
	AND MakeFlag =1 
	AND Weight >148
GO
--Parallel Plan اجبار به استفاده از 
SELECT 
	PP.[ProductID]
	,[Name]
	,[ProductNumber]
	,PTH.ActualCost 
	,PTH.TransactionType      
FROM [Production].[Product] PP
INNER JOIN [Production].TransactionHistory PTH
	ON PP.ProductID =PTH.ProductID 
WHERE 
	PP.SellEndDate <GETDATE()-2 
	AND MakeFlag =1 
	AND Weight >148
OPTION(QUERYTRACEON 8649)
GO
--SQl Server 2016 SP1 
SELECT 
	PP.[ProductID]
	,[Name]
	,[ProductNumber]
	,PTH.ActualCost 
	,PTH.TransactionType      
FROM [Production].[Product] PP
INNER JOIN [Production].TransactionHistory PTH
	ON PP.ProductID =PTH.ProductID 
WHERE 
	PP.SellEndDate <GETDATE()-2 
	AND MakeFlag =1 
	AND Weight >148
OPTION(USE HINT('ENABLE_PARALLEL_PLAN_PREFERENCE'))
-------------------------------------
--Partition Type بررسی 
USE AdventureWorks2017
GO
SELECT 
	PP.[ProductID]
	,[Name]
	,[ProductNumber]
	,PTH.ActualCost 
	,PTH.TransactionType      
FROM [Production].[Product] PP
INNER JOIN [Production].TransactionHistory PTH
	ON PP.ProductID =PTH.ProductID 
WHERE 
	PP.SellEndDate <GETDATE()-2 
	AND MakeFlag =1 
	AND Weight >148
OPTION(USE HINT('ENABLE_PARALLEL_PLAN_PREFERENCE'))
GO
-------------------------------------
--تمرین 3
/*
USE AdventureWorksDW2017
GO
SELECT
    fis.SalesAmount,
    dd.CalendarYear
FROM
    dbo.FactInternetSales fis
    INNER JOIN dbo.DimDate dd ON dd.DateKey = fis.OrderDateKey
GO
SELECT
    fis.SalesAmount,
    dd.CalendarYear
FROM
    dbo.FactInternetSales fis
    INNER JOIN dbo.DimDate dd ON dd.DateKey = fis.OrderDateKey
OPTION(USE HINT('ENABLE_PARALLEL_PLAN_PREFERENCE'))
*/