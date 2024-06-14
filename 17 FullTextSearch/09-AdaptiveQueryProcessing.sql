
/*
برای این دمو نیاز به نمایش
داریم Actual Execution Plan
*/
GO
USE WideWorldImporters
GO
/*
Compatibility Level تنظیم  
SQL Server SQL Server 2016
*/
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 130
GO
/*
Plan Cache پاک کردن
DBCC FREEPROCCACHE
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO
--Multi Statement Functionبررسی ایجاد 
CREATE OR ALTER FUNCTION dbo.MSTVF_SalesOrders(@N INT)
	RETURNS @T TABLE
		(
			CustomerID NVARCHAR(40), 
			OrderID NVARCHAR(40)
		)
WITH SCHEMABINDING
AS
BEGIN
    INSERT @t(CustomerID, OrderID)
    SELECT TOP(@N)
        CustomerID
       ,OrderID 
    FROM
        Sales.Orders;
    RETURN;
END
GO
--MSTVF استفاده از 
SELECT
    C = COUNT_BIG(*)
FROM
    Sales.Invoices  c 
    INNER JOIN dbo.MSTVF_SalesOrders(10500) t 
       ON t.CustomerID = c.CustomerID AND t.orderid=c.orderid
GO
--Cardinality Estimation in SQL Server>= 2016 = 100
--------------------------------------------------------------------
USE WideWorldImporters
GO
/*
Compatibility Level تنظیم  
SQL Server SQL Server 2014
*/
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON;
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 120
GO
/*
Plan Cache پاک کردن
DBCC FREEPROCCACHE
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO
--MSTVF استفاده از 
SELECT
    C = COUNT_BIG(*)
FROM
    Sales.Invoices  c 
    INNER JOIN dbo.MSTVF_SalesOrders(10500) t 
       ON t.CustomerID = c.CustomerID AND t.orderid=c.orderid
GO
--Cardinality Estimation in SQL Server<= 2014 = 1
--------------------------------------------------------------------
/*
Compatibility Level تنظیم  
SQL Server SQL Server 2017
*/
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140
GO
/*
Plan Cache پاک کردن
DBCC FREEPROCCACHE
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO
--MSTVF استفاده از 
SELECT
    C = COUNT_BIG(*)
FROM
    Sales.Invoices  c 
    INNER JOIN dbo.MSTVF_SalesOrders(10500) t 
       ON t.CustomerID = c.CustomerID AND t.orderid=c.orderid
GO
--Cardinality Estimation in SQL Server>= 2017 = 1
GO
--------------------------------------------------------------------
/*
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON;
*/
--------------------------------------------------------------------
/*
Adaptive Join
Nested Loop  , Hash Match انتخاب هوشمندانه مابین 
*/

/*
برای این دمو نیاز به نمایش
داریم Actual Execution Plan
*/
GO
USE AdventureWorks2017
GO
/*
Filter Columnstore Index ساخت یک ایندکس 
Execution= Batch Mode وجود آن باعث رفتن پلن به سمت 
*/
DROP INDEX IX_Dummy ON Sales.SalesOrderHeader
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Dummy ON Sales.SalesOrderHeader(SalesOrderID) 
	WHERE SalesOrderID = -1 and SalesOrderID = -2;
GO
DECLARE @TerritoryID int = 1;
SELECT
	SUM(soh.SubTotal)
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod ON 
	soh.SalesOrderID = sod.SalesOrderID
WHERE 
	soh.TerritoryID = @TerritoryID
GO
DECLARE @TerritoryID int = 1;
SELECT
	SUM(soh.SubTotal)
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod ON 
	soh.SalesOrderID = sod.SalesOrderID
WHERE 
	soh.TerritoryID = @TerritoryID
OPTION (RECOMPILE,USE HINT('DISABLE_BATCH_MODE_ADAPTIVE_JOINS'))

