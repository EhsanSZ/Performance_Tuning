
/*
Where Condition عدم استفاده از عبارت های محاسباتی در 
*/
GO
--Show Actual Execution Plan 
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
USE AdventureWorks2017
GO
SELECT * FROM  Purchasing.PurchaseOrderHeader AS poh
	WHERE  poh.PurchaseOrderID * 2 = 3400 ;
GO
SELECT * FROM  Purchasing.PurchaseOrderHeader AS poh
	WHERE  poh.PurchaseOrderID  = 3400/2 ;
GO


