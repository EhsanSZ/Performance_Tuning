
/*
MAXDOP استفاده از
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
--بازیابی بانک اطلاعاتی
RESTORE DATABASE DemoPageOrganization FROM DISK ='C:\Temp\DemoPageOrganization.bak' WITH 
	MOVE 'DemoPageOrganization' TO 'C:\Temp\DemoPageOrganization.mdf',
	MOVE 'DemoPageOrganization_log' TO 'C:\Temp\DemoPageOrganization_log.lmdf',
	STATS=1
GO
--------------------------------------------------------------------
--ساخت ایندکس 
USE DemoPageOrganization
GO
--بررسی جهت وجود ایندکس و حذف آن
DROP INDEX IF EXISTS IX_Clustered ON HeapTable
GO
--Actual Execution Plan نمایش
BEGIN TRANSACTION
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON HeapTable(OrderDateKey,SalesOrderNumber,ProductKey,SalesOrderLineNumber)
	WITH (MAXDOP=1)
ROLLBACK TRANSACTION
GO
BEGIN TRANSACTION
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON HeapTable(OrderDateKey,SalesOrderNumber,ProductKey,SalesOrderLineNumber)
	WITH (MAXDOP=0)
ROLLBACK TRANSACTION
/*MAXDOP : MAX Degree Of Parallelism 
هاي درگير جهت ساخت ايندكس را مشخص مي كندprocessorتعداد 
IF MAXDOP=1 THEN : Suppresses parallel plan generation
IF MAXDOP>1 THEN : maximum number of processors used in a parallel index (2-64)
IF MAXDOP=0 (default) : Uses the actual number of processors or fewer based on the current system workload
*/
SP_CONFIGURE 'Max Degree of Parallelism'
GO

