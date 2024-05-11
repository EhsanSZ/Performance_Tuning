
--Show Actual Execution Plan 
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
USE AdventureWorks2017
GO
DECLARE @N INT
SELECT 
	@N = COUNT(*)
FROM  Sales.SalesOrderDetail AS OD
	WHERE  OD.OrderQty = 1 ;
IF @N > 0
	PRINT 'Record Exists' ;
GO
IF EXISTS 
	( 
		SELECT 
			OD.* 
		FROM  Sales.SalesOrderDetail AS OD
			WHERE  OD.OrderQty = 1 
	)
	PRINT 'Record Exists';
GO
--------------------------------------------------------------------
--به جای ستاره از یک فیلد خاص استفاده شود
DECLARE @N INT
SELECT 
	@N = COUNT(OD.SalesOrderDetailID)
FROM  Sales.SalesOrderDetail AS OD
	WHERE  OD.OrderQty = 1 ;
IF @N > 0
	PRINT 'Record Exists' ;
GO
IF EXISTS 
	( 
		SELECT 
			OD.SalesOrderDetailID
		FROM  Sales.SalesOrderDetail AS OD
			WHERE  OD.OrderQty = 1 
	)
	PRINT 'Record Exists';