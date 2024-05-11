
USE AdventureWorks2017
GO
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
--Nested loop * Show Execution Plan * Estimate Number Of Execution
/*
Outer Input : ورودی بالا + اجرا صرفا یک مرتبه
Inner Input : ورودی پایین + اجرا به ازای هر رکورد 
*/
SELECT 
	e.BusinessEntityID
FROM HumanResources.Employee AS e
INNER  JOIN Sales.SalesPerson  AS s
ON e.BusinessEntityID = s.BusinessEntityID
GO
--------------------------------------------------------------------
--Merge loop * Show Execution Plan * Estimate Number Of Execution
/*
Outer Input : ورودی بالا + اجرا صرفا یک مرتبه
Inner Input : ورودی پایین + اجرا صرفا یک مرتبه 

در دو مرحله است Join کار این نوع 
Sort مرتب سازی
Merge


مرتب شده باشد Join باید بر اساس شرط Merge Join هر دو ورودی 
این الگوریتم به طور همزمان یک رکورد از هر ورودی خوانده و آنها را مقایسه می کند 

برای مقایسه به انیمشن توجه شود
1-یک رکورد از هر دو ورودی خوانده می شود
2-در صورت مساوی بودن نمایش داده می شود
3-اگر لیست اول کوچکتر از لیست دوم باشد مقدار لیست اول خوانده می شود ....
3-اگر لیست اول کوچکتر از لیست دوم نباشد خواندن از لیست دوم ادامه پیدا می کند ....

TableA (4,5,6,7,8) Merge Join  TableB(1,2,3,4,5,6,7,8)
*/
SELECT 
	POH.PurchaseOrderID,POH.OrderDate,
	POD.ProductID,POD.DueDate,POH.VendorID
 FROM Purchasing.PurchaseOrderHeader POH
	INNER JOIN Purchasing.PurchaseOrderDetail POD
		ON POH.PurchaseOrderID=POD.PurchaseOrderID
GO
--------------------------------------------------------------------
--Hash Match * Show Execution Plan * Estimate Number Of Execution + cardinality estimation
/*
در حافظه Hash Table کوچکترین ورودی پیدا می شود برای ایجاد یک 
خواهد بودTempDB اگر دیتا بزرگ باشد و حافظه جا نداشته باشد ایجاد جدول در  
 زمانی رخ می دهد که آمار به روز نباشد و به اشتباه یک جدول بزرگ به عنوان جدول کوچک در نظر گرفته شود در این حالت زمان اجرا طولانی می شود:role reversal
*/
SELECT 
	S.*
FROM  [Sales].[Store] s
INNER JOIN [Sales].SalesPerson AS sp
ON s.SalesPersonID = sp.BusinessEntityID
GO
--------------------------------------------------------------------
--بوده استHash Match قبلا
/*
     { LOOP | HASH | MERGE}  
*/
SELECT 
	S.*
FROM  [Sales].[Store] s
INNER JOIN [Sales].SalesPerson AS sp
ON s.SalesPersonID = sp.BusinessEntityID
GO
--به آیتم مرتب سازی دقت کنید به واسطه تغییر الگوریتم بوجود آمده است
SELECT 
	S.*
FROM  [Sales].[Store] s
INNER MERGE JOIN [Sales].SalesPerson AS sp
ON s.SalesPersonID = sp.BusinessEntityID
GO
SELECT 
	S.*
FROM  [Sales].[Store] s
INNER LOOP JOIN [Sales].SalesPerson AS sp
ON s.SalesPersonID = sp.BusinessEntityID
