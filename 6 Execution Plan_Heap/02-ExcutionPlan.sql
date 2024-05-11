
 --Execution Plan بررسی مقدماتی 
 /*
 به صورت سادهExecution Plan نمایش یک 
 Execution Plan بررسی نحوه خواندن 
 Exectuin Plan بررسی نحوه جستجو در 
 Execution Plan بررسی نحوه زوم کردن 
 */
USE AdventureWorks2017
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE 
	CustomerID = 29994 
GROUP BY 
	SalesPersonID, YEAR(OrderDate) 
HAVING 
	COUNT(*) > 1 
ORDER BY 
	OrderYear DESC 
GO
--------------------------------------------------------------------
/*
Operator بررسی مفهوم 
Cost بررسی مفهوم 
بررسی مفهوم خطوط
هاTooltip بررسی
Properties بررسی
Estimated I/O Cost
Estimated CPU Cost
Estimated Operator Cost
Estimated Subtree Cost
Estimated Number of Rows
Estimated Row Size
*/
SELECT 
	*
FROM Sales.SalesOrderHeader H 
INNER JOIN Sales.SalesOrderDetail D ON H.SalesOrderID=D.SalesOrderID
GO