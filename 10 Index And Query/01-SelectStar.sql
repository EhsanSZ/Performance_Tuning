
--Show Actual Execution Plan 
USE AdventureWorks2017
GO
--دو کوئری عین هم هستند فقط در تعداد فیلدهای بازگشتی با هم فرق دارند

--SELECT * استفاده از
SELECT * FROM Sales.SalesOrderDetail
	WHERE SalesOrderID>50000 AND OrderQty>1
GO	
--SELECT * عدم استفاده از
SELECT 
	SalesOrderID,CarrierTrackingNumber,OrderQty
	,ProductID,SpecialOfferID,UnitPrice 
FROM Sales.SalesOrderDetail
	WHERE SalesOrderID>50000 AND OrderQty>1
GO
--Show  Client Statistics And Run Agin For Each Query
GO
--------------------------------------------------------------------
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
--SELECT * استفاده از
SELECT * FROM  Sales.SalesTerritory AS st
	WHERE  st.[Name] = 'Australia' 
GO
--SELECT * عدم استفاده از
SELECT 
	[Name],TerritoryID
FROM  Sales.SalesTerritory AS st
	WHERE  st.[Name] = 'Australia' ;
GO
