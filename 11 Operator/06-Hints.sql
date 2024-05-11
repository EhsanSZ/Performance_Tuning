
/*
های مشهورHint بررسی استفاده از 
*/

--FORCE ORDER بررسی 
USE Northwind
GO
--بررسی تعداد رکوردهای جداول
SELECT COUNT(*) AS 'Count_Employees' FROM Employees
SELECT COUNT(*) AS 'Count_Customers' FROM Customers
SELECT COUNT(*) AS 'Count_Orders' FROM Orders
GO
--جداول در حالت عادی Join
--به ترتیب نوشتن جداول دقت شود
SELECT 
	*
FROM Orders O
INNER JOIN Employees E ON E.EmployeeID=O.EmployeeID
INNER JOIN Customers C ON C.CustomerID=O.CustomerID
GO
--Force Order جداول در حالت Join
--به ترتیب نوشتن جداول دقت شود
SELECT 
	*
FROM Orders O
INNER JOIN Employees E ON E.EmployeeID=O.EmployeeID
INNER JOIN Customers C ON C.CustomerID=O.CustomerID
OPTION(FORCE ORDER)
GO
--------------------------------------------------------------------
--Force Scan,Force Seek 
USE AdventureWorks2017
GO
--FORCESCAN اجبار به استفاده از 
SELECT 
	*
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d  WITH (FORCESCAN)
    ON h.SalesOrderID = d.SalesOrderID 
WHERE 
	h.TotalDue > 100
	AND (d.OrderQty > 5 OR d.LineTotal < 1000.00);
GO
--FORCESEEK اجبار به استفاده از 
SELECT
	*
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d WITH (FORCESEEK)
    ON h.SalesOrderID = d.SalesOrderID 
WHERE 
	h.TotalDue > 100
	AND (d.OrderQty > 5 OR d.LineTotal < 1000.00);
GO
--------------------------------------------------------------------
--Fast N اجبار به استفاده از 
SELECT
	SalesOrderID
	,RevisionNumber
	,OrderDate
	,DueDate
	,ShipDate
	,Status
	,OnlineOrderFlag
	,SalesOrderNumber
	,PurchaseOrderNumber
FROM Sales.SalesOrderHeader 
ORDER BY OrderDate
GO
SELECT
	SalesOrderID
	,RevisionNumber
	,OrderDate
	,DueDate
	,ShipDate
	,Status
	,OnlineOrderFlag
	,SalesOrderNumber
	,PurchaseOrderNumber
FROM Sales.SalesOrderHeader 
ORDER BY OrderDate DESC
OPTION (FAST 100)

