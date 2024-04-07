
USE AdventureWorks2017;
GO

/*
Work Table و RANGE و ROWS
*/

SET STATISTICS IO ON;
GO

SELECT
	CustomerID, SalesOrderID, TotalDue,
	SUM(TotalDue) OVER( PARTITION BY CustomerID
						ORDER BY SalesOrderID ) AS Sum_TotalDue
FROM Sales.SalesOrderHeader;
GO

SELECT
	CustomerID, SalesOrderID, TotalDue,
	SUM(TotalDue) OVER( PARTITION BY CustomerID
						ORDER BY SalesOrderID
						ROWS UNBOUNDED PRECEDING ) AS Sum_TotalDue
FROM Sales.SalesOrderHeader;
GO
--------------------------------------------------------------------

-- !لطفا هیچ‌گاه چنین هنرنمایی‌هایی را انجام ندهید
DECLARE @Offset INT = 2;
SELECT
	CustomerID, OrderDate,
	LAG(OrderDate,@Offset) OVER( PARTITION BY CustomerID
								 ORDER BY SalesOrderID ) AS Prv_OrderDate
FROM Sales.SalesOrderHeader;
GO

SELECT
	CustomerID, OrderDate,
	LAG(OrderDate,2) OVER( PARTITION BY CustomerID
						   ORDER BY SalesOrderID ) AS Prv_OrderDate
FROM Sales.SalesOrderHeader;
GO
--------------------------------------------------------------------

-- !همواره به نحوه کوئری‌نویسی توجه ویژه‌ای داشته باشید

DROP INDEX IF EXISTS Sales.SalesOrderHeader.IX_SalesOrderHeader_CustomerID_OrderDate;
GO

SP_HELPINDEX 'Sales.SalesOrderHeader';
GO

SELECT
	CustomerID,
	OrderDate,
	SalesOrderID,
	ROW_NUMBER() OVER ( PARTITION BY CustomerID
						ORDER BY OrderDate ) AS Row_Num
FROM Sales.SalesOrderHeader;
GO

CREATE INDEX IX_SalesOrderHeader_CustomerID_OrderDate ON Sales.SalesOrderHeader(CustomerID,OrderDate);
GO

SELECT
	CustomerID,
	OrderDate,
	SalesOrderID,
	ROW_NUMBER() OVER ( PARTITION BY CustomerID
						ORDER BY OrderDate ) AS Row_Num
FROM Sales.SalesOrderHeader;
GO

SP_HELPINDEX 'Sales.Customer';
GO

/*
.خروجی کوئری‌هایی که در ادامه آمده است همانند یکدیگر است
*/
SELECT
	SOH.CustomerID,
	SOH.SalesOrderID,
	SOH.OrderDate,
	C.TerritoryID,
	ROW_NUMBER() OVER ( PARTITION BY SOH.CustomerID
						ORDER BY SOH.OrderDate ) AS Row_Num
FROM Sales.SalesOrderHeader AS SOH
JOIN Sales.Customer AS C
	ON SOH.CustomerID = C.CustomerID;
GO

WITH Sales
AS
(
	SELECT
		CustomerID,
		OrderDate,
		SalesOrderID,
		ROW_NUMBER() OVER ( PARTITION BY CustomerID
							ORDER BY OrderDate ) AS Row_Num
	FROM Sales.SalesOrderHeader
)
SELECT
	Sales.CustomerID,
	Sales.SalesOrderID,
	Sales.OrderDate,
	C.TerritoryID,
	Sales.Row_Num
FROM Sales
JOIN Sales.Customer AS C
	ON C.CustomerID = Sales.CustomerID;
GO