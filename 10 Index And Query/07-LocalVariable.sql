
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
GO
USE AdventureWorks2017
GO
/*
--Show Actual Execution Plan 
--Display Estimated Number Of Row
--Display Actual Number Of Row 
به تعداد رکوردهای بازگشتی در بحث تخمین دقت شود
*/
GO
--Local Variable مقدار دهی با استفاده از 
DECLARE @id INT = 1 ;
SELECT 
	pod.*
FROM  Purchasing.PurchaseOrderDetail AS pod
INNER JOIN  Purchasing.PurchaseOrderHeader AS poh
	ON poh.PurchaseOrderID = pod.PurchaseOrderID
WHERE  
	poh.PurchaseOrderID >= @id ;
GO
--Local Variable مقدار دهی بدون استفاده از 
SELECT 
	pod.*
FROM  Purchasing.PurchaseOrderDetail AS pod
INNER JOIN  Purchasing.PurchaseOrderHeader AS poh
	ON poh.PurchaseOrderID = pod.PurchaseOrderID
WHERE  
	poh.PurchaseOrderID >= 1
GO