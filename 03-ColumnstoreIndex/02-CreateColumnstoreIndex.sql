
GO
USE AdventureWorksDW2017
GO
SP_HELP FactResellerSales
GO
--بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS FactResellerSales2
GO
--تهیه کپی از جدول
SELECT * INTO FactResellerSales2 FROM FactResellerSales
GO
--بررسی وجود ایندکس
SP_HELPINDEX FactResellerSales2
GO
--ساخت ایندکس کلاستر
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON FactResellerSales2(SalesOrderNumber, SalesOrderLineNumber)
GO
--Clustered Columnstore Index ایجاد
DROP INDEX IX_Clustered ON FactResellerSales2
GO
CREATE CLUSTERED COLUMNSTORE INDEX IX_CLUSTERED_COLUMNSTORE ON FactResellerSales2
SP_SPACEUSED FactResellerSales2
GO
SET STATISTICS IO ON 
SELECT * FROM FactResellerSales2 WHERE CustomerPONumber='PO17371111245'
GO

--انجام بدم CustomerPONumber می خواهم سرچ روی 
SELECT * FROM FactResellerSales2 WITH (INDEX(0)) WHERE CustomerPONumber='PO17371111245'
SELECT * FROM FactResellerSales2 WHERE CustomerPONumber='PO17371111245'

GO
--Clustered Columnstore Index روی NonClustered Index ساخت 
--CustomerPONumber
GO
CREATE NONCLUSTERED INDEX IX_CustomerPONumber ON FactResellerSales2(CustomerPONumber)

--------------------------------------------------------------------
/*
NonClustered Columnstore Index بررسی ساخت 
*/
GO
USE AdventureWorksDW2017
GO
--کوئری مورد استفاده ما در سیستم
SELECT 
	ProductKey,
	COUNT(ProductKey)
FROM FactInternetSales2
WHERE 
	OrderDateKey BETWEEN  20110101 AND 20110501
GROUP BY ProductKey
GO
--بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS FactResellerSales2
GO
--تهیه کپی از جدول
SELECT * INTO FactResellerSales2 FROM FactResellerSales
GO
SP_HELP FactResellerSales2
GO
SP_HELPINDEX FactResellerSales2
GO
SP_SPACEUSED FactResellerSales2
GO
--ساخت ایندکس کلاستر
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON FactResellerSales2(SalesOrderNumber, SalesOrderLineNumber)
GO

--NonClustered Columnstore Index ایجاد
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_NCCI ON FactResellerSales2(ProductKey,OrderDateKey,EmployeeKey,SalesAmount)
GO
SP_HELPINDEX FactResellerSales2
GO
SET STATISTICS IO ON 
SELECT 
	ProductKey,
	SUM(SalesAmount) AS SumSalesAmount,
	COUNT(ProductKey) AS CountofProduct
FROM FactResellerSales2
GROUP BY ProductKey
GO
SELECT 
	ProductKey,
	SUM(SalesAmount) AS SumSalesAmount,
	COUNT(ProductKey) AS CountofProduct
FROM FactResellerSales2 WITH (INDEX(IX_Clustered))
GROUP BY ProductKey
GO
SELECT 
	ResellerKey,
	SUM(SalesAmount) AS SumSalesAmount,
	COUNT(ProductKey) AS CountofProduct
FROM FactResellerSales2
GROUP BY ResellerKey
GO
CREATE NONCLUSTERED INDEX IX_CustomerPONumber ON FactResellerSales2(CustomerPONumber)
SELECT * FROM FactResellerSales2 WHERE CustomerPONumber='PO17371111245'


--NonClustered Index ایجاد 
--CustomerPONumber 
GO
--------------------------------------------------------------------
/*
Memory Optimized Table بر روی Columnstore Index ایجاد 
*/
GO
USE SQL2016_Demo
GO
--Memory Optimized Table  + Columnstore Index ترکیب
CREATE TABLE Account 
(
    accountkey int NOT NULL PRIMARY KEY NONCLUSTERED,
    Accountdescription nvarchar (50),
    accounttype nvarchar(50),
    unitsold int,
    INDEX t_account_cci CLUSTERED COLUMNSTORE
    )
    WITH (MEMORY_OPTIMIZED = ON );
GO 