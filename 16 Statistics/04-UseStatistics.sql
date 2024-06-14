
/*
Statistics بررسی نحوه استفاده از 
نحوه تشخیص استفاده از ایندکس مناسب
*/
USE Northwind
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('Orders2')>0
	DROP TABLE Orders2
GO
--تهیه کپی از جدول
SELECT * INTO Orders2 FROM Orders
GO
CREATE CLUSTERED INDEX IX_C ON Orders2 (OrderID)
--دو ایندکس ایجاد می کنیمOrders2 بر روی جدول
CREATE NONCLUSTERED INDEX IX_ShipCountry ON Orders2(ShipCountry) 
	INCLUDE (EmployeeID)
GO
CREATE NONCLUSTERED INDEX IX_EmployeeID ON Orders2(EmployeeID)  
	INCLUDE (ShipCountry)
GO
SP_HELPINDEX Orders2
GO
--بررسی پلن اجرایی جهت مشاهده ایندکس مورد استفاده
SELECT OrderID,ShipCountry,EmployeeID FROM  Orders2 
	WHERE ShipCountry='USA' AND EmployeeID=5
GO
--حتی اگر جای شرط را عوض کنید باز هم از همان ایندکس قبلی استفاده خواهد شد
SELECT OrderID,ShipCountry,EmployeeID FROM  Orders2  
	WHERE EmployeeID=5 AND ShipCountry='USA' 
GO
--از كجا مي فهمد كه از كدام ايندكس استفاده كند به نفعش استSQL
--ShipCountry ايندكس مربوط به  
--EmployeeID ايندكس مربوط به  
GO
DBCC SHOW_STATISTICS('Orders2','IX_EmployeeID') --EmployeeID=5 :  42 RECORD
DBCC SHOW_STATISTICS('Orders2','IX_ShipCountry') --ShipCountry='USA' : 122 RECORD
--استفاده مي شودIX_EmployeeIDپس از ايندكس
GO
--بررسی پلن اجرایی جهت مشاهده ایندکس مورد استفاده
SELECT OrderID,EmployeeID,ShipCountry FROM  Orders2 
	WHERE ShipCountry='USA' AND EmployeeID=5
GO
--حتی اگر جای شرط را عوض کنید باز هم از همان ایندکس قبلی استفاده خواهد شد
SELECT OrderID,EmployeeID,ShipCountry FROM  Orders2 
	WHERE EmployeeID=5 AND ShipCountry='USA' 
GO
--از كجا مي فهمد كه از كدام ايندكس استفاده كند به نفعش استSQL
--ShipCountry ايندكس مربوط به  
--EmployeeID ايندكس مربوط به  
GO
DBCC SHOW_STATISTICS('Orders2','IX_EmployeeID') --EmployeeID=5 :  42 RECORD
DBCC SHOW_STATISTICS('Orders2','IX_ShipCountry') --ShipCountry='USA' : 122 RECORD


