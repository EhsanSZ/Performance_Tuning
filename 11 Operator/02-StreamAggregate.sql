
/*
Stream Aggregate بررسی
مناسب برای ورودی های کوچک 
*/
USE AdventureWorks2017
GO
--Show Actual Execution Plan 
SELECT 
	TerritoryID, 
    AVG(Bonus) AS 'Average bonus', 
    SUM(SalesYTD) AS'YTD sales'
FROM Sales.SalesPerson
GROUP BY 
	TerritoryID
GO
-----------------------------------
/*
Stream Aggregate ایجاد یک مثال برای بررسی 
*/
GO
USE tempdb
GO
--بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS Orders
GO
--ساخت جدول
CREATE TABLE dbo.Orders
(
	OrderID INT NOT NULL,
	CustomerId INT NOT NULL,
	Total MONEY NOT NULL,
	CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED(OrderID)
)
GO
--پر کردن جدول با استفاده از داده تستی
;with N1(C) as (select 0 union all select 0) -- 2 rows
,N2(C) as (select 0 from N1 as T1 cross join N1 as T2) -- 4 rows
,N3(C) as (select 0 from N2 as T1 cross join N2 as T2) -- 16 rows
,N4(C) as (select 0 from N3 as T1 cross join N3 as T2) -- 256 rows
,Nums(Num) as (select row_number() over (order by (select null)) from N4)
insert into dbo.Orders(OrderId, CustomerId, Total)
SELECT 
	Num, Num % 10 + 1, Num 
FROM Nums
GO
--مشاهده حجم رکوردهای درج شده در جدول
SP_SPACEUSED Orders
GO
--Execution Plan اجرای کوئری و مشاهده 
SELECT 
	Customerid, 
	SUM(Total) AS [Total Sales]
FROM dbo.Orders
GROUP BY CustomerId;