-
--Show Actual Execution Plan 
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
USE AdventureWorks2017
GO
--IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode
--بررسی ایندکس های مربوط به فیلد
SP_HELPINDEX 'Person.Address' 
GO
--بررسی نوع داده های فیلد
--AddressLine1 NVarchar(60)
SP_HELP 'Person.Address' 
GO
--داده های موجود در ایندکس
SELECT  
	DISTINCT AddressID,AddressLine1, AddressLine2, City, StateProvinceID, PostalCode
FROM Person.Address
	ORDER BY AddressLine1, AddressLine2, City, StateProvinceID, PostalCode
GO
--پلن تمام کوئری ها بررسی شود
SELECT 
	AddressID, AddressLine1, AddressLine2, 
	City, StateProvinceID, PostalCode
FROM Person.Address
	WHERE AddressLine1 LIKE '710%'; --(Prefix)
GO
SELECT 
	AddressID, AddressLine1, AddressLine2, 
	City, StateProvinceID, PostalCode
FROM Person.Address
	WHERE AddressLine1 LIKE '%710%';
GO
SELECT 
	AddressID, AddressLine1, AddressLine2, 
	City, StateProvinceID, PostalCode
FROM Person.Address
	WHERE AddressLine1 LIKE '%710';
