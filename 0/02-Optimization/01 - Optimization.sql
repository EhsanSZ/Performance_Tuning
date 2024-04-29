
USE AdventureWorks2017;
GO

-- در پلن اجرایی کوئری Sequence Project و Segment اپراتورهای
SELECT
	CustomerID,
	ROW_NUMBER() OVER(ORDER BY SalesOrderID) AS Row_Num
FROM Sales.SalesOrderHeader;
GO

/*
Sequence Project عدم مشاهده اپراتور
.که باید مورد توجه قرار گیرند Table Spool و Sort اپراتورهای
*/
SELECT
	CustomerID, SalesOrderID,
	SUM(TotalDue) OVER(PARTITION BY CustomerID) AS SubTotal
FROM Sales.SalesOrderHeader;
GO
--------------------------------------------------------------------

SET STATISTICS IO ON;
GO

-- Message در بخش Worktable توجه به موضوع
SELECT
	CustomerID, SalesOrderID,
	SUM(TotalDue) OVER(PARTITION BY CustomerID) AS SubTotal
FROM Sales.SalesOrderHeader;
GO