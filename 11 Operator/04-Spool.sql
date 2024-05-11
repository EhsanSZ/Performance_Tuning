
/*
Eager Spool

Data Consistency برای Spool اعمال 
وجود نداشت یک حلقه بی نهایت  Spool در این مثال اگر عملیات 
هنگام خواندن دیتا از جدول ایجاد می شود
*/
USE tempdb
GO
DROP TABLE IF EXISTS HalloweenProtection
GO
CREATE TABLE HalloweenProtection
(
	ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	SampleData INT NOT NULL
)
GO
--Actual Execution Plan نمایش
INSERT INTO HalloweenProtection(SampleData)
	SELECT 
		SampleData 
	FROM HalloweenProtection
GO
USE AdventureWorks2017
GO
SET STATISTICS IO ON
GO
--Actual Execution Plan نمایش
/*
تمام ردیف ها را از ورودی خود می خواند و تا زمانی که خوانده Eager Spool
شدن تمام نشده باشد کار بعدی انجام نمی شود ، ماهیت این اپراتور از نوع بلاکینگ است
*/
UPDATE Person.Person SET 
	FirstName = 'Ted'
WHERE FirstName = 'Ted'
GO
SET STATISTICS IO OFF
GO
----------------------------------
/*
Lazy Spool

رخ می دهد Spool هر زمان که نیاز به خواندن یک ردیف باشد عملیات 
است Non Blocking ماهیت این اپراتور 
*/
USE tempdb
GO
--بررسی جهت وجود جدول و حذف آن
DROP TABLE IF EXISTS Orders
GO
--ایجاد جدول تستی
CREATE TABLE Orders
(
    OrderID INT NOT NULL,
    CustomerId INT NOT NULL,
    Total MONEY NOT NULL,
    CONSTRAINT PK_Orders
	PRIMARY KEY CLUSTERED(OrderID)
)
GO
--درج دیتا تستی در جدول
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,NUMS(NUM) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N4)
INSERT INTO dbo.Orders(OrderId, CustomerId, Total)
    SELECT Num, Num % 10 + 1, Num
    FROM Nums
GO
SET STATISTICS IO ON
GO
--کوئری Execution Plan مشاهده 
/*
یکبار ایجاد شده و چندین بار مورد استفاده قرار می گیردTable Spool
دقت شود Node ID , Primary Node ID به 
*/
SELECT 
	OrderId, CustomerID, Total
	,SUM(Total) OVER(PARTITION BY CustomerID) AS [Total Customer Sales] 
FROM dbo.Orders
GO
SET STATISTICS IO OFF
GO
----------------------------------
/*
Spool ها و مسئاله Function
آیا جدول با داده سر و کار دارد که ساختار: With Schema Binding وجود 

در صورتی که جدول با داده سرور کار داشته باشد
 داریم Spool و مسئاله  Hallowen Protection

در صورتی که جدول با داده سرور کار داشته باشد
 نداریم Spool و مسئاله  Hallowen Protection
 استفاده کنیمWith Schema Binding به شرطی که 
*/
USE tempdb
GO
DROP TABLE IF EXISTS HalloweenProtection
GO
CREATE TABLE HalloweenProtection
(
	ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	SampleData INT NOT NULL
)
GO
CREATE OR ALTER FUNCTION dbo.ShouldUpdateData(@ID INT)
RETURNS BIT
AS
BEGIN
	RETURN (1)
END
GO
CREATE OR ALTER FUNCTION dbo.ShouldUpdateDataSchemaBound(@ID INT)
RETURNS BIT
WITH SCHEMABINDING
AS
BEGIN
	RETURN (1)
END
GO
--کوئری Execution Plan مشاهده 
UPDATE dbo.HalloweenProtection SET SampleData = 0 WHERE dbo.ShouldUpdateData(ID) = 1;
UPDATE dbo.HalloweenProtection SET SampleData = 0 WHERE dbo.ShouldUpdateDataSchemaBound(ID) = 1;
GO
----------------------------------
/*
NO_PERFORMANCE_SPOOL
ارائه شده از نسخه 2016 به بعد
Spool به عدم استفاده از Optimizer اجبار 
در دیسک انجام شود در برخی مواقع این روش مفید استSpool اگر عملیات 
*/
USE AdventureWorks2017
GO
SET STATISTICS IO ON 
GO
SELECT 
	sp.BusinessEntityID, sp.TerritoryID,
    (
		SELECT 
			SUM(TaxAmt)
	    FROM Sales.SalesOrderHeader AS soh  
		WHERE soh.TerritoryID = sp.TerritoryID
	)
FROM   
	Sales.SalesPerson AS sp
GO
SELECT 
	sp.BusinessEntityID, sp.TerritoryID,
    (
		SELECT 
			SUM(TaxAmt)
	    FROM Sales.SalesOrderHeader AS soh  
		WHERE soh.TerritoryID = sp.TerritoryID
	)
FROM   
	Sales.SalesPerson AS sp
OPTION (NO_PERFORMANCE_SPOOL)
GO