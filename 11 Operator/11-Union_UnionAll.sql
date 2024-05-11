
USE AdventureWorks2017
GO
SET STATISTICS IO ON
GO
--Show Execution Plan
SELECT * FROM  Sales.SalesOrderHeader AS soh
	WHERE  soh.SalesOrderNumber LIKE '%47808'
UNION
SELECT * FROM  Sales.SalesOrderHeader AS soh
	WHERE  soh.SalesOrderNumber LIKE '%65748' ;
GO
SELECT * FROM  Sales.SalesOrderHeader AS soh
	WHERE  soh.SalesOrderNumber LIKE '%47808'
UNION ALL
SELECT * FROM  Sales.SalesOrderHeader AS soh
	WHERE  soh.SalesOrderNumber LIKE '%65748' ;
GO