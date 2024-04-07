--------------------------------------------------------------------
/*
استفاده کنیم Columnstore Index کجا از 
استفاده نکنیم Columnstore Index کجا از 
*/
USE master
GO
IF DB_ID('DemoPageOrganization')>0
BEGIN
	ALTER DATABASE DemoPageOrganization SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DemoPageOrganization
END
GO
RESTORE FILELISTONLY FROM DISK ='C:\Temp\DemoPageOrganization.bak'
GO
RESTORE DATABASE DemoPageOrganization FROM DISK ='C:\Temp\DemoPageOrganization.bak' WITH 
	MOVE 'DemoPageOrganization' TO 'E:\Dump\DemoPageOrganization.mdf',
	MOVE 'DemoPageOrganization_log' TO 'E:\Dump\DemoPageOrganization_log.lmdf',
	STATS=1
GO
USE DemoPageOrganization
GO
CREATE INDEX IX_SalesOrderNumber ON ClusteredTable(SalesOrderNumber)
GO
--------------------------------------------------------------------
/*
اجرای کوئری های تحلیلی مشاهده 
Execution Plan
IO
*/
DBCC DROPCLEANBUFFERS
CHECKPOINT
GO
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
/*
حتما بررسی زمان اجرای کوئری انجام شود 
*/
GO
USE DemoPageOrganization
GO
--ColumnstoreTable اجرای کوئری برای جدول 
SELECT  
	*
FROM ColumnstoreTable
WHERE OrderDateKey  BETWEEN 20020701 AND 20020710
GO
--ClusteredTable اجرای کوئری برای جدول 
SELECT  
	*
FROM ClusteredTable
WHERE OrderDateKey  BETWEEN 20020701 AND 20020710
GO
--------------------------------------------------------------------
--ColumnstoreTable اجرای کوئری برای جدول 
SELECT  
	*
FROM ColumnstoreTable
WHERE SalesOrderNumber ='SO44281-20020705-32'
GO
--ClusteredTable اجرای کوئری برای جدول 
SELECT  
	*
FROM ClusteredTable
WHERE SalesOrderNumber ='SO44281-20020705-32'
GO


CREATE INDEX IX_SalesOrderNumber ON ColumnstoreTable (SalesOrderNumber)
GO

UPDATE ColumnstoreTable SET SalesAmount=10
	WHERE SalesOrderNumber ='SO44281-20020705-32'
GO
---------------------

SP_HELPINDEX ClusteredTable

SP_HELP ClusteredTable

CREATE NONCLUSTERED COLUMNSTORE INDEX IX_NCC ON ClusteredTable
(
ProductKey
,OrderDateKey
,DueDateKey
,ShipDateKey
,ResellerKey
,EmployeeKey
,PromotionKey
,SalesAmount
)

SELECT 
	OrderDateKey,
	SUM(SalesAmount)
FROM ClusteredTable WITH (INDEX(1))
GROUP BY OrderDateKey


SELECT 
	OrderDateKey,
	SUM(SalesAmount)
FROM ClusteredTable
GROUP BY OrderDateKey



SELECT 
ProductKey
,OrderDateKey
,DueDateKey
,ShipDateKey
,ResellerKey
FROM ClusteredTable 
WHERE ProductKey=349
ORDER BY OrderDateKey

ALTER DATABASE [DemoPageOrganization] SET COMPATIBILITY_LEVEL = 130
UPDATE ClusteredTable SET SalesAmount=10
	WHERE SalesOrderNumber ='SO44281-20020705-32'
GO

ALTER DATABASE [DemoPageOrganization] SET COMPATIBILITY_LEVEL = 140
UPDATE ClusteredTable SET SalesAmount=10
	WHERE SalesOrderNumber ='SO44281-20020705-32'
