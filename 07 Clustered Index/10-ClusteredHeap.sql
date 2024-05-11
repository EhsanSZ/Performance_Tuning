
/*
کم حجم بودن کلاستر ایندکس
*/
--ایجاد بانک اطلاعاتی تستی
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO
--------------------------------------------------------------------
/*
ایجاد جداول
*/
USE  MyDB2017
GO
--بررسی وجود جداول
IF OBJECT_ID('Orders_ClusteredTable')>0
	DROP TABLE Orders_ClusteredTable
GO
IF OBJECT_ID('Orders_HeapTable')>0
	DROP TABLE Orders_HeapTable
GO
SELECT * INTO Orders_ClusteredTable FROM Northwind.dbo.Orders

SELECT * INTO Orders_HeapTable FROM Northwind.dbo.Orders
GO
CREATE CLUSTERED INDEX IX_CLUSTERED ON Orders_ClusteredTable (ORDERID)
GO
SET STATISTICS IO ON

SELECT * FROM Orders_ClusteredTable
SELECT * FROM Orders_HeapTable

SET STATISTICS IO ON 
SELECT * FROM Orders_ClusteredTable WHERE ORDERID=10292
SELECT * FROM Orders_HeapTable WHERE ORDERID=10292
GO
--------------------------------------------------------------------
SET IDENTITY_INSERT Orders_ClusteredTable ON

--درج دیتا در جدول هیپ و کلاستر
INSERT  Orders_ClusteredTable
	(
		OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, 
		ShipCity, ShipRegion, ShipPostalCode, ShipCountry
	)
SELECT 
		1, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, 
		ShipCity, ShipRegion, ShipPostalCode, ShipCountry
FROM Orders_ClusteredTable
WHERE 
	OrderID 	=10259
GO
SET IDENTITY_INSERT Orders_ClusteredTable OFF
GO
SET IDENTITY_INSERT Orders_HeapTable ON
GO
INSERT  Orders_HeapTable
	(
		OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, 
		ShipCity, ShipRegion, ShipPostalCode, ShipCountry
	)
SELECT 
		1, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, 
		ShipCity, ShipRegion, ShipPostalCode, ShipCountry
FROM Orders_HeapTable
WHERE 
	OrderID 	=10259
GO
SET IDENTITY_INSERT Orders_HeapTable OFF
GO

SELECT * FROM Orders_HeapTable
GO
SELECT * FROM Orders_ClusteredTable
GO
