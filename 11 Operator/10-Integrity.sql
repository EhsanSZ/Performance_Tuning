
USE AdventureWorks2017
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('ProductDemo')>0
	DROP TABLE ProductDemo
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('ProductModelDemo')>0
	DROP TABLE ProductModelDemo
GO
--تهیه کپی از جداول
SELECT * INTO ProductModelDemo FROM Production.ProductModel
SELECT * INTO ProductDemo FROM Production.Product WHERE ProductModelID IS NOT NULL
GO
--اضافه کردن یک فیلد به جدول
ALTER TABLE ProductDemo ALTER COLUMN ProductModelID INT NOT NULL
GO
--بررسی ساختار جدول
SP_HELP ProductDemo
GO
--تعیین کلید اصلی جدول 
ALTER TABLE ProductDemo ADD CONSTRAINT PK_ProductDemo_ProductID
	PRIMARY KEY CLUSTERED  (ProductID ASC)
GO
--تعیین کلید اصلی جدول 
ALTER TABLE ProductModelDemo ADD CONSTRAINT PK_ProductModelDemo_ProductModelID 
	PRIMARY KEY CLUSTERED (ProductModelID ASC)
GO
SET STATISTICS IO ON 
GO
--Show Execution Plan
--اگر این فیلد دارای مقدار نال بود باید جدول بررسی می شد
SELECT * FROM ProductDemo WHERE ProductModelID IS NULL
GO
--Show Execution Plan
--به فیلدهای جدول توجه کنید
-- دو جدول نمایش داده شده اندJoinبه واسطه 
SELECT 
	P.ProductID
	,P.ProductModelID
FROM ProductDemo AS P
	JOIN ProductModelDemo AS PM
		ON P.ProductModelID=PM.ProductModelID
			WHERE P.ProductID=680
GO
--ایجاد ارتباط بین جداول
ALTER TABLE ProductDemo
WITH CHECK ADD CONSTRAINT FK_ProductDemo_ProductModelDemo_ProductModelID
FOREIGN KEY (ProductModelID) 
REFERENCES ProductModelDemo(ProductModelID)
GO
--Show Execution Plan
--به فیلدهای انتخاب شده در کوئری توجه کنید
SELECT 
	P.ProductID
	,P.ProductModelID
FROM ProductDemo AS P
	JOIN ProductModelDemo AS PM
		ON P.ProductModelID=PM.ProductModelID
			WHERE P.ProductID=680
GO
SELECT 
	P.ProductID
	,P.ProductModelID
	,PM.CatalogDescription
FROM ProductDemo AS P
	JOIN ProductModelDemo AS PM
		ON P.ProductModelID=PM.ProductModelID
			WHERE P.ProductID=680
GO
-------------------------------------------------------
--در هنگام درج به جداول ارتباط داده شده توجه کنید
INSERT INTO ProductDemo
SELECT 
 Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color, SafetyStockLevel, 
ReorderPoint, StandardCost, ListPrice, Size, SizeUnitMeasureCode, WeightUnitMeasureCode,
 Weight, DaysToManufacture, ProductLine, Class, Style, ProductSubcategoryID, ProductModelID,
  SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate
FROM ProductDemo
	WHERE ProductID=999
GO
--اگر جداول فاقد ارتباط باشند
ALTER TABLE ProductDemo  NOCHECK CONSTRAINT FK_ProductDemo_ProductModelDemo_ProductModelID
GO
INSERT INTO ProductDemo
SELECT 
 Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color, SafetyStockLevel, 
ReorderPoint, StandardCost, ListPrice, Size, SizeUnitMeasureCode, WeightUnitMeasureCode,
 Weight, DaysToManufacture, ProductLine, Class, Style, ProductSubcategoryID, ProductModelID,
  SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate
FROM ProductDemo
	WHERE ProductID=999
GO