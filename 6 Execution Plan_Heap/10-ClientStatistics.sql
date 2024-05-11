
/*
Client Statistics مشاهده 
*/
USE AdventureWorks2017
GO
SELECT 
	* 
FROM HumanResources.Employee e
INNER JOIN HumanResources.EmployeePayHistory eh 
	ON eh.BusinessEntityID = e.BusinessEntityID
GO
SELECT 
	* 
FROM HumanResources.Employee e
INNER JOIN HumanResources.EmployeePayHistory eh 
	ON eh.BusinessEntityID = e.BusinessEntityID
GO
SELECT 
	COUNT(*) 
FROM HumanResources.Employee e
INNER JOIN HumanResources.EmployeePayHistory eh 
	ON eh.BusinessEntityID = e.BusinessEntityID