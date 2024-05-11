
 --Execution Plan بررسی انواع فرمت های 
 GO
/*
Estimated Execution Plan 
قالب گرافیکی (Ctrl + L)
*/
USE AdventureWorks2017
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
/*
Estimated Execution Plan 
قالب متنی (SHOWPLAN_ALL)
*/
SET SHOWPLAN_ALL ON
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
SET SHOWPLAN_ALL OFF
GO
/*
Estimated Execution Plan 
قالب متنی (SHOWPLAN_TEXT)
*/
SET SHOWPLAN_TEXT ON
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
SET SHOWPLAN_TEXT OFF
GO
/*
Estimated Execution Plan 
XML قالب (SHOWPLAN_XML)
*/
SET SHOWPLAN_XML ON
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
SET SHOWPLAN_XML OFF
GO
--------------------------------------------------------------------
/*
Actual Execution Plan 
قالب گرافیکی (Ctrl + M)
*/
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
/*
Actual Execution Plan 
قالب متنی (STATISTICS PROFILE)
*/
SET STATISTICS PROFILE ON
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
SET STATISTICS PROFILE OFF
GO
/*
Actual Execution Plan 
XML قالب (STATISTICS XML)
*/
SET STATISTICS XML ON
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
SET STATISTICS XML OFF
