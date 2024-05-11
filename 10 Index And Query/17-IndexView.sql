
USE Northwind
GO
--به خروجي دستور فوق دقت كنيد
SELECT c.CompanyName, o.OrderDate, o.OrderID, od.ProductID 
	 FROM Customers C 
		INNER JOIN dbo.orders O ON c.CustomerID=o.CustomerID  
			INNER JOIN [Order Details] od ON o.OrderID=od.OrderID   
GO
--Show Execution Plan
SELECT c.CompanyName, o.OrderDate, o.OrderID, od.ProductID 
	 FROM Customers C 
		INNER JOIN dbo.orders O ON c.CustomerID=o.CustomerID  
			INNER JOIN [Order Details] od ON o.OrderID=od.OrderID   
GO
----------------------------------------------------------------------
--ايجاد يك ويو عادي بدون ايندكس
CREATE OR ALTER VIEW  View_Index01
AS 
SELECT c.CompanyName, o.OrderDate, o.OrderID, od.ProductID 
	 FROM Customers C 
		INNER JOIN dbo.orders O ON c.CustomerID=o.CustomerID  
			INNER JOIN [Order Details] od ON o.OrderID=od.OrderID   
GO
SELECT * FROM View_Index01 --Show Execution Plan
GO
----------------------------------------------------------------------
--ويوي مورد نظر كليه شرايط را براي ساخت ايندكس دارد
DROP VIEW  IF EXISTS View_Index02
GO
CREATE VIEW  View_Index02
WITH SCHEMABINDING
AS 
SELECT c.CompanyName, o.OrderDate, o.OrderID, od.ProductID 
	 FROM dbo.Customers C 
		INNER JOIN dbo.orders O ON c.CustomerID=o.CustomerID  
			INNER JOIN dbo.[Order Details] od ON o.OrderID=od.OrderID   
GO
----------------------------------------------------------------------
CREATE UNIQUE CLUSTERED INDEX IX1 ON 
	View_Index02(OrderID, ProductID) 
GO
SELECT * FROM View_Index02 WITH(NOEXPAND)--توجه كنيد Hint به اين    
SELECT * FROM View_Index02 
SELECT * FROM View_Index01
GO
--------------------------------------------------------------------
--بنابراين اگر درجي در يكي از جداول مورد استفاده ويو انجام يابد
--ايندكس مربوط به ويو نيز به شكل خودكار به روز خواهد شد
GO
USE Northwind
GO
/*
Execution Plan نمایش 
کوئری IO بررسی 
*/
SET STATISTICS IO ON 
GO
--به روز رسانی یک رکورد
SELECT * FROM Customers WHERE CustomerID='Alfki'
UPDATE Customers SET CompanyName='NikAmooz' WHERE CustomerID='Alfki'
SELECT * FROM Customers WHERE CustomerID='Alfki'
GO
--مشاهده ایندکس ویو
SELECT * FROM View_Index02 WITH(NOEXPAND)--توجه كنيد Hint به اين    
	WHERE CompanyName LIKE 'ALF%'
GO
SELECT * FROM View_Index02 WITH(NOEXPAND)--توجه كنيد Hint به اين    
	WHERE CompanyName LIKE 'NIKA%'
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
USE tempdb
GO
--بررسی جهت وجود جدول و حذف آن
DROP TABLE IF EXISTS OrderLineItems
DROP TABLE IF EXISTS Products
GO
--ساخت یک جدول ساده
CREATE TABLE dbo.Products
(
	ProductID INT NOT NULL,
	ProductName NVARCHAR(100) NOT NULL,
	CONSTRAINT PK_Product PRIMARY KEY CLUSTERED(ProductID)
)
GO
CREATE TABLE dbo.OrderLineItems
(
    OrderId INT NOT NULL,
    OrderLineItemId INT NOT NULL IDENTITY(1,1),
    Quantity DECIMAL(9,3) NOT NULL,
    Price SMALLMONEY NOT NULL,
    ProductID INT NOT NULL,
    CONSTRAINT PK_OrderLineItems PRIMARY KEY CLUSTERED(OrderId,OrderLineItemId),
    CONSTRAINT FK_OrderLineItems_Products FOREIGN KEY(ProductId) REFERENCES dbo.Products(ProductId)
)
GO
--اعمال ایندکس کلاستر بر روی جدول
CREATE INDEX IDX_OrderLineItems_ProductId ON dbo.OrderLineItems(ProductId);
GO
--Products درج رکورد در جدول 
INSERT INTO Products(ProductID,ProductName)
SELECT  
	P.ProductID,P.Name 
FROM AdventureWorks2017.Production.Product P
GO
--OrderLineItems درج رکورد در جدول 
INSERT INTO OrderLineItems(OrderId,Quantity,Price,ProductID)
SELECT 
	SalesOrderID,OrderQty,
	UnitPrice,ProductID 
FROM AdventureWorks2017.Sales.SalesOrderDetail
GO
--بررسی رکوردهای درج شده در جداول
SELECT * FROM Products
SELECT * FROM OrderLineItems
GO
----------------------------------
--گزارش برای داشبورد
SELECT 
	p.ProductID, p.ProductName,
	SUM(o.Quantity) AS TotalQuantity,
	COUNT_BIG(*) AS CountOrderLine
FROM dbo.OrderLineItems o 
INNER JOIN dbo.Products p 
	ON o.ProductId = p.ProductId
GROUP BY
	P.ProductId, p.ProductName
GO
--ایجاد ویو برای گزارش
CREATE OR ALTER VIEW dbo.vProductSaleStats
WITH SCHEMABINDING
AS
SELECT 
	p.ProductID, p.ProductName,
	SUM(o.Quantity) AS TotalQuantity,
	COUNT_BIG(*) AS CountOrderLine
FROM dbo.OrderLineItems o 
INNER JOIN dbo.Products p 
	ON o.ProductId = p.ProductId
GROUP BY
	P.ProductId, p.ProductName
GO
--ایجاد ایندکس ها
CREATE UNIQUE CLUSTERED INDEX IDX_vProductSaleStats_ProductId ON dbo.vProductSaleStats(ProductId);
GO
CREATE NONCLUSTERED INDEX IDX_vClientOrderTotal_TotalQuantity ON dbo.vProductSaleStats(TotalQuantity DESC)
	INCLUDE(ProductName)
GO
/*
Execution Plan نمایش 
کوئری IO بررسی 
*/
SET STATISTICS IO ON 
GO
--استخراج دیتا از ایندکس ویو
SELECT TOP 10 
	ProductId, ProductName, 
	TotalQuantity,CountOrderLine
FROM dbo.vProductSaleStats
ORDER BY TotalQuantity DESC
GO
--استخراج دیتا از اصل جدول
SELECT TOP 10
	p.ProductID, p.ProductName,
	SUM(o.Quantity) AS TotalQuantity,
	COUNT_BIG(*) AS CountOrderLine
FROM dbo.OrderLineItems o WITH (INDEX(0))
INNER JOIN dbo.Products p WITH (INDEX(0))
	ON o.ProductId = p.ProductId
GROUP BY
	P.ProductId, p.ProductName
GO
/*
--هنگام استفاده از ایندکس ویو دقت شود که آیا دستورات تغییر داده ها پروسه ایندکس اسکن را انجام می دهند 
--در صورتیکه این گونه باشد باید با یک ایندکس مفید آنها را تنظیم کرد
*/