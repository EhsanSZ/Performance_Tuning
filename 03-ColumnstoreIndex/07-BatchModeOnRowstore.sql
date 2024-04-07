
--------------------------------------------------------------------
/*
Row Based برای جداول Batch Process استفاده از ویژگی 
*/
GO
USE ContosoRetailDW
GO
--مشاهده حجم دو جدول
SP_SPACEUSED FactOnlineSales      
GO
SP_SPACEUSED DimCustomer
GO
--مشاهده ایندکس های دو جدول
SP_HELPINDEX FactOnlineSales      
GO
SP_HELPINDEX DimCustomer
GO
/*
Execution Plan مشاهده 
چگونه است Batch روش تبدیل مدل پردازش به حالت 
*/
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
GO
--SQL Server 2017
ALTER DATABASE ContosoRetailDW SET COMPATIBILITY_LEVEL = 140
GO
SELECT 
	C.CompanyName,
	COUNT(DISTINCT F.SalesOrderNumber) AS OrderCount,
	COUNT(F.SalesOrderLineNumber) AS OrderLineCount,
	SUM(F.SalesAmount) AS SumSalesAmount
FROM FactOnlineSales F
INNER JOIN DimCustomer C ON 
	F.CustomerKey=C.CustomerKey
GROUP BY 
	C.CompanyName
GO
--SQL Server 2019
ALTER DATABASE ContosoRetailDW SET COMPATIBILITY_LEVEL = 150
GO
SELECT 
	C.CompanyName,
	COUNT(DISTINCT F.SalesOrderNumber) AS OrderCount,
	COUNT(F.SalesOrderLineNumber) AS OrderLineCount,
	SUM(F.SalesAmount) AS SumSalesAmount
FROM FactOnlineSales F
INNER JOIN DimCustomer C ON 
	F.CustomerKey=C.CustomerKey
GROUP BY 
	C.CompanyName
GO

--مقایسه دو حالت با هم انجام شود

/*
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = ON
OPTION(RECOMPILE, USE HINT('ALLOW_BATCH_MODE'))
*/