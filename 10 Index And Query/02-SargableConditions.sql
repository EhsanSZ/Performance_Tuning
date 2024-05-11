
--Show Actual Execution Plan 
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
USE AdventureWorks2017
GO
SELECT * FROM Sales.SalesOrderHeader
	WHERE SalesOrderID =75000
--Show IO & Scan Count & Show Seek Predicates (Execution Plan)
--sargable operators
SELECT * FROM Sales.SalesOrderHeader
	WHERE SalesOrderID  IN (75000,75001,75002)
GO
SELECT * FROM Sales.SalesOrderHeader
	WHERE SalesOrderID=75000 OR SalesOrderID=75001 OR SalesOrderID=75002
GO
SELECT * FROM Sales.SalesOrderHeader
	WHERE SalesOrderID >=75000 AND SalesOrderID<=75002
GO
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID BETWEEN 75000 AND 75002
GO
--------------------------------------------------------------------
--!< Condition vs. >= Condition
 -- دارد optimize query syntax هر دو کوئری در هر حالت یکسان هستند فقط کوئری دوم مرحله 
 --شرط کوئری های مثل آدم نوشته شود
SELECT * FROM  Purchasing.PurchaseOrderHeader AS poh
	WHERE  poh.PurchaseOrderID >= 2975 
GO
--optimize query syntax
SELECT * FROM  Purchasing.PurchaseOrderHeader AS poh
	WHERE  poh.PurchaseOrderID !< 2975 
GO

