
 GO
/*
Execution Plan ذخیره و بازیابی 
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
