
/*
Hash Aggregate بررسی
مناسب برای ورودی های بزرگ
*/
USE AdventureWorks2017
GO
--Show Actual Execution Plan 
SELECT 
	SalesOrderHeader.TerritoryID, 
	COUNT(*) AS 'Count of Row',
	SUM (SalesOrderHeader.SubTotal) AS 'Sum of SubTotal'
FROM Sales.SalesOrderHeader
GROUP BY 
	SalesOrderHeader.TerritoryID
GO


/*
--1)Query1
SET STATISTICS IO ON 
USE AdventureWorks2017
GO
SELECT 
	TerritoryID, 
    AVG(Bonus) AS 'Average bonus', 
    SUM(SalesYTD) AS'YTD sales'
FROM Sales.SalesPerson
GROUP BY 
	TerritoryID
GO

CREATE INDEX IX_TerritoryID ON Sales.SalesPerson(TerritoryID)
	INCLUDE (Bonus,SalesYTD)
WITH (DROP_EXISTING=ON)

--2)Query2
SELECT 
	SalesOrderHeader.TerritoryID, 
	COUNT(*) AS 'Count of Row',
	SUM (SalesOrderHeader.SubTotal) AS 'Sum of SubTotal'
FROM Sales.SalesOrderHeader
GROUP BY 
	SalesOrderHeader.TerritoryID
GO
SELECT 
	SalesOrderHeader.TerritoryID, 
	COUNT(*) AS 'Count of Row',
	SUM (SalesOrderHeader.SubTotal) AS 'Sum of SubTotal'
FROM Sales.SalesOrderHeader WITH(INDEX(1))
GROUP BY 
	SalesOrderHeader.TerritoryID
GO

CREATE INDEX IX_TerritoryID ON  Sales.SalesOrderHeader(TerritoryID)
	INCLUDE (SubTotal)
WITH (DROP_EXISTING=ON)

*/