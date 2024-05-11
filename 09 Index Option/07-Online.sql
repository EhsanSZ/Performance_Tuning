
/*
Online استفاده از
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
/*
ساخت ایندکس به صورت آنلاین
زمان ساخت ایندکس ، وضعیت لاک ها و تعداد لاگ رکوردها بررسی شود 
*/

/*
بررسی وضعیت لاک ها در زمان ساخت ایندکس
*/
USE DemoPageOrganization
GO
--بررسی جهت وجود ایندکس و حذف آن
DROP INDEX IF EXISTS IX_Clustered ON HeapTable
GO
BEGIN TRANSACTION
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON HeapTable(OrderDateKey,SalesOrderNumber,ProductKey,SalesOrderLineNumber)
ROLLBACK TRANSACTION
GO
BEGIN TRANSACTION
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON HeapTable(OrderDateKey,SalesOrderNumber,ProductKey,SalesOrderLineNumber)
	WITH (ONLINE=ON)
ROLLBACK TRANSACTION
GO
--دیگر Session مشاهده در یک 
SELECT COUNT(*) FROM HeapTable
GO
--مشاهده لاک های مربوط به ایجاد ایندکس
SELECT 
	dtl.request_session_id,
	dtl.resource_database_id,
	dtl.resource_associated_entity_id,
	dtl.resource_type,
	dtl.resource_description,
	dtl.request_mode,
	dtl.request_status
FROM  sys.dm_tran_locks AS dtl
	WHERE  dtl.request_session_id = XXX ;
GO
--------------------------------------------------------------------
/*
بررسی زمان ساخت ایندکس و تعداد لاگ رکوردهای ثبت شده در لاگ فایل
*/
USE DemoPageOrganization
GO
--بررسی جهت وجود ایندکس و حذف آن
DROP INDEX IF EXISTS IX_Clustered ON HeapTable
GO
CHECKPOINT
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
GO
------------------------------------
BEGIN TRANSACTION
SET STATISTICS TIME ON
--ساخت ایندکس به صورت آفلاین
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON HeapTable(OrderDateKey,SalesOrderNumber,ProductKey,SalesOrderLineNumber)
SET STATISTICS TIME OFF
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
ROLLBACK TRANSACTION
GO
CHECKPOINT
CHECKPOINT
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
GO
BEGIN TRANSACTION
SET STATISTICS TIME ON
--ساخت ایندکس به صورت آنلاین
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON HeapTable(OrderDateKey,SalesOrderNumber,ProductKey,SalesOrderLineNumber)
	WITH (ONLINE=ON)
SET STATISTICS TIME OFF
--مشاهده حجم لاگ های ثبت شده
SELECT
       COUNT(*) as nb_records,
       SUM([Log Record Length])/ 1024 as kbytes
FROM sys.fn_dblog(NULL, NULL)
ROLLBACK TRANSACTION
GO
CHECKPOINT
DBCC SHRINKFILE(2,1)
