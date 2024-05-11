
/*
Rebuild & Reorganize بررسي   
*/
USE master
GO
--ساخت بانک اطلاعاتی
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO
DROP TABLE IF EXISTS T1
DROP TABLE IF EXISTS T2
GO
--به کلید اصلی جدول توجه کنید
CREATE TABLE T1
(
	ID INT IDENTITY NOT NULL,
	Filler CHAR(8000) NULL, 
	PRIMARY KEY CLUSTERED (ID ASC) --صعودی
)
GO
--به کلید اصلی جدول توجه کنید
CREATE TABLE T2
(
	ID INT IDENTITY NOT NULL,
	Filler CHAR(8000) NULL, 
	PRIMARY KEY CLUSTERED (ID DESC)--نزولی
)
GO
--به ایندکس این جدول دقت کنید
SP_HELPINDEX T1
GO
--به ایندکس این جدول دقت کنید
SP_HELPINDEX T2
GO
--درج دیتای تستی در هر دو جدول
INSERT INTO T1 DEFAULT VALUES
GO 3000
INSERT INTO T2 DEFAULT VALUES
GO 3000

--Fragmentation بررسی وضعیت
SELECT object_name(object_id) AS name, 
       page_count, 
       avg_fragmentation_in_percent, 
       fragment_count
FROM sys.dm_db_index_physical_stats(db_id(), 0, NULL, NULL, 'DETAILED') 
WHERE  index_level = 0  AND object_id IN (object_id('T1') ,object_id('T2'))
----------------------------------------
--Fragmentationرفع مشکل 
----------------------------------------
SELECT object_name(object_id) AS name, 
       page_count, 
       avg_fragmentation_in_percent, 
       fragment_count
FROM sys.dm_db_index_physical_stats(db_id(), object_id('T2'), 1, NULL, 'DETAILED') 
GO
--کردن ایندکسRebuild
ALTER INDEX ALL ON T2 REBUILD WITH (ONLINE=ON)
GO
--کردن ایندکسReorganize
--ALTER INDEX ALL ON T2 REORGANIZE WITH (ONLINE=ON)
GO
SELECT object_name(object_id) AS name, 
       page_count, 
       avg_fragmentation_in_percent, 
       fragment_count
FROM sys.dm_db_index_physical_stats(db_id(), object_id('T2'), 1, NULL, 'DETAILED') 
GO
--با هر بار انجام اینکار تنظیمات ایندکس از بین خواهد رفت با تنظیمات جدید را اعمال کنید
ALTER INDEX ALL ON T2 REBUILD WITH (ONLINE=ON,FILLFACTOR=85)
GO

--Rebuild نکاتی در خصوص 
/*
است تنظیمات زیر را انجام دهیدBulk Operation چون عملیات فوق یک
1-Create Log Backup
2-Set Bulk_Logged Recovery Model
3-Rebuild Index
*/
GO
--بالای استIO دارای REBUILD
GO
--------------------------------------------------------------------
/*
ایندکس Rebuild Online برای PRIORITY  تعیین 
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
USE DemoPageOrganization
GO
--بررسی جهت وجود ایندکس و حذف آن
DROP INDEX IF EXISTS IX_Clustered ON HeapTable
GO
--ایندکس ساخته شود
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON HeapTable(OrderDateKey,SalesOrderNumber,ProductKey,SalesOrderLineNumber)
GO
--دیگر انجام شود Session این کار در یک 
BEGIN TRANSACTION
UPDATE HeapTable SET SalesAmount=SalesAmount*2 
	WHERE SalesOrderNumber='SO43659-20040413-49'
GO
/*
Self : عملیات آنلاین کنسل می شود
None : تلاش برای اتمام کار همان حالت عادی
Blockers : هر کاربری که عملیات آنلاین را بلاک کرده کنسل می شود
*/
--دیگر انجام شود Session این کار در یک 
ALTER INDEX IX_Clustered ON HeapTable REBUILD
	WITH ( ONLINE = ON)
GO
ALTER INDEX IX_Clustered ON HeapTable REBUILD
	WITH ( ONLINE = ON ( WAIT_AT_LOW_PRIORITY (MAX_DURATION = 1 minutes, ABORT_AFTER_WAIT = NONE )))
GO
ALTER INDEX IX_Clustered ON HeapTable REBUILD
	WITH ( ONLINE = ON ( WAIT_AT_LOW_PRIORITY (MAX_DURATION = 1 minutes, ABORT_AFTER_WAIT = SELF )))
GO
ALTER INDEX IX_Clustered ON HeapTable REBUILD
	WITH ( ONLINE = ON ( WAIT_AT_LOW_PRIORITY (MAX_DURATION = 1 minutes, ABORT_AFTER_WAIT = Blockers )))
GO
--Session مشاهده بلاکینگ در همین 
SELECT
	db.name DBName,
	tl.request_session_id,
	wt.blocking_session_id,
	tl.resource_type,
	h1.TEXT AS RequestingText,
	h2.TEXT AS BlockingTest,
	tl.request_mode
FROM sys.dm_tran_locks AS tl
INNER JOIN sys.databases db ON db.database_id = tl.resource_database_id
INNER JOIN sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
INNER JOIN sys.dm_exec_connections ec1 ON ec1.session_id = tl.request_session_id
INNER JOIN sys.dm_exec_connections ec2 ON ec2.session_id = wt.blocking_session_id
CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2
GO
SP_WHO2 58
GO
--------------------------------------------------------------------
/*
Resumable Online Index Rebuild پیاده سازی 
*/
GO
USE DemoPageOrganization
GO
ALTER DATABASE DemoPageOrganization SET RECOVERY SIMPLE
DBCC SHRINKFILE(2,1)
CHECKPOINT
GO
SP_HELPFILE
GO
--بررسی حجم لاگ فایل
SELECT
    used_log_space_in_bytes / 1024.0 / 1024.0  as used_log_space_MB,
    log_space_in_bytes_since_last_backup / 1024.0 / 1024.0 AS log_space_MB_since_last_backup,
    used_log_space_in_percent
FROM sys.dm_db_log_space_usage
GO
--دیگر انجام شود Session این کار در یک 
ALTER INDEX IX_Clustered ON ClusteredTable REBUILD
	WITH ( ONLINE = ON,RESUMABLE=ON)
GO
--دیگر انجام شود Session این کار در یک 
ALTER INDEX IX_Clustered ON ClusteredTable PAUSE
GO
--دیگر انجام شود Session این کار در یک 
ALTER INDEX IX_Clustered ON ClusteredTable RESUME
GO
ALTER INDEX IX_Clustered ON ClusteredTable ABORT
GO
--جدید DMV بررسی 
SELECT 
	total_execution_time, percent_complete, 
	name,state_desc,last_pause_time,page_count
FROM sys.index_resumable_operations
GO