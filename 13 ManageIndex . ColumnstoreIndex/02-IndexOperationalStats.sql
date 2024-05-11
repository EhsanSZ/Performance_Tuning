
--Restart SQL Service
GO
USE Northwind
GO
/*
sys.dm_db_index_operational_stats
 (
	  { database_id | NULL | 0 | DEFAULT }
	, { object_id | NULL | 0 | DEFAULT }
	, { index_id | 0 | NULL | -1 | DEFAULT }
	, { partition_number | NULL | 0 | DEFAULT }
)
*/
GO
--بررسی خروجی
--خروجی تابع پس از ریستارت از بین می رود
SELECT * FROM sys.dm_db_index_operational_stats
(
	DB_ID(),
	OBJECT_ID('Orders'),
	NULL,
	NULL
)
GO
SELECT * FROM Orders
-------------------------------------------------------------------------
--DML Activity
/*
--شامل فیلدهای زیر می باشد
leaf_insert_count  : Cumulative count of leaf-level rows inserted
leaf_delete_count  : Cumulative count of leaf-level rows deleted
leaf_update_count  : Cumulative count of leaf-level rows updated
leaf_ghost_count   : Cumulative count of leaf-level rows that are 
					 marked to be deleted, but not yet removed
nonleaf_insert_count : Cumulative count of inserts above the leaf 
					   level. For heaps, this value will always be 0.
nonleaf_delete_count : Cumulative count of deletes above the leaf 
					   level. For heaps, this value will always be 0.
nonleaf_update_count : Cumulative count of updates above the leaf 
					   level. For heaps, this value will always be 0.
*/
-------------------------------------------------------------------------
USE tempdb
GO
--بررسی جهت وجود جدول 
IF OBJECT_ID('KungFu')>0
	DROP TABLE KungFu
GO
--ایجاد جدول
CREATE TABLE KungFu
(
	KungFuID INT PRIMARY KEY ,
	Hustle BIT
)
GO
--درج داده تستی در جدول
INSERT INTO KungFu
SELECT 
	ROW_NUMBER() OVER (ORDER BY t.object_id)
	,t.object_id % 2
FROM sys.objects t
GO
SELECT * FROM KungFu
GO
--حذف رکوردها
DELETE FROM KungFu
	WHERE Hustle = 0
GO
--به روزرسانی رکوردها
UPDATE KungFu SET Hustle = 0
	WHERE Hustle = 1
GO
SELECT 
	OBJECT_SCHEMA_NAME(ios.object_id) + '.' + OBJECT_NAME(ios.object_id) AS table_name
	,i.name AS index_name
	,ios.leaf_insert_count
	,ios.leaf_update_count
	,ios.leaf_delete_count
	,ios.leaf_ghost_count
FROM sys.dm_db_index_operational_stats(DB_ID(),NULL,NULL,NULL) ios
	INNER JOIN sys.indexes i 
		ON i.object_id = ios.object_id AND i.index_id = ios.index_id
WHERE ios.object_id = OBJECT_ID('KungFu')
ORDER BY ios.range_scan_count DESC
GO
-------------------------------------------------------------------------
--SELECT Activity
/*
--شامل فیلدهای زیر می باشد
range_scan_count        : count of range and table scans started on the index or heap
singleton_lookup_count  : count of single row retrievals from the index or heap
forwarded_fetch_count   : Count of rows that were fetched through a forwarding record
*/
-------------------------------------------------------------------------
--Range Scan : Index Scan
USE AdventureWorks2017
GO
--کوئری اجرا و پلن اجرایی واقعی مشخص شود
SELECT 
	* 
FROM Sales.SalesOrderDetail 
WHERE 
	SalesOrderID BETWEEN 54099 AND 64099
GO
--Range Scanمشاهده 
SELECT 
	OBJECT_NAME(ios.object_id) AS table_name
	,i.name AS index_name
	,ios.range_scan_count
FROM sys.dm_db_index_operational_stats(DB_ID(),OBJECT_ID('Sales.SalesOrderDetail'),NULL,NULL) ios
INNER JOIN sys.indexes i
	ON i.object_id = ios.object_id
	AND i.index_id = ios.index_id
ORDER BY 
	ios.range_scan_count DESC
GO
-----------------------
--Singleton Lookup : Bookmark Lookup
USE AdventureWorks2017
GO
--کوئری اجرا و پلن اجرایی واقعی مشخص شود
SELECT 
* 
FROM Sales.SalesOrderDetail
	WHERE ProductID=709
GO
SELECT 
	OBJECT_NAME(ios.object_id) AS table_name
	,i.name AS index_name
	,ios.singleton_lookup_count
FROM 
	sys.dm_db_index_operational_stats(DB_ID(),OBJECT_ID('Sales.SalesOrderDetail'),NULL,NULL) ios
INNER JOIN sys.indexes i
	ON i.object_id = ios.object_id AND i.index_id = ios.index_id
ORDER BY 
	ios. singleton_lookup_count DESC
GO
--می توان به این نتیجه رسید که آیا ایندکس ارزش کاور شدن دارد
GO
-----------------------
--Forwarded Fetch : Table Update Forward Record عملیات 
USE tempdb
GO
--بررسی جهت وجود جدول 
IF OBJECT_ID('ForwardedRecords')>0
	DROP TABLE ForwardedRecords
GO
--ایجاد جدول
CREATE TABLE ForwardedRecords
(
	ID INT IDENTITY(1,1)
	,VALUE VARCHAR(8000)
)
--درج تعدادی رکورد تستی
--به تعداد رکوردهای درج شده دقت شود
INSERT INTO ForwardedRecords (VALUE)
	SELECT REPLICATE(type, 500) FROM sys.objects
GO
--کوئری اجرا و پلن اجرایی واقعی مشخص شود
UPDATE ForwardedRecords
	SET VALUE = REPLICATE(VALUE, 16)
		WHERE ID%3 = 1;
GO
SELECT 
	OBJECT_NAME(ios.object_id) AS table_name
	,i.name AS index_name
	,ios.forwarded_fetch_count
FROM 
	sys.dm_db_index_operational_stats(DB_ID(),OBJECT_ID('ForwardedRecords'),NULL,NULL) ios
INNER JOIN sys.indexes i
	ON i.object_id = ios.object_id AND i.index_id = ios.index_id
ORDER BY 
	ios.forwarded_fetch_count DESC
GO
-------------------------------------------------------------------------
--Locking Contention (نزاع حاصل از لاک)
/*
--شامل فیلدهای زیر می باشد
row_lock_count		: Cumulative number of row locks requested
row_lock_wait_count : Cumulative number of times the database engine  waited on a row lock
row_lock_wait_in_ms : Total number of milliseconds the database engine waited on a row lock
page_lock_count		: Cumulative number of page locks requested
page_lock_wait_count : Cumulative number of times the database engine waited on a page lock
page_lock_wait_in_ms : Total number of milliseconds the database engine waited on a page lock
index_lock_promotion_attempt_count : Cumulative number of times the database engine tried to escalate locks
index_lock_promotion_count : Cumulative number of times the database engine escalated locks

attempt : قصد
promotion : ارتقاء
*/
-------------------------------------------------------------------------
--Row Lock :هنگام دسترسی به ایندکس اگر قفلی به ازای ردیف ایجاد شود در این فیلداعمال می شود
USE AdventureWorks2017
GO
--واکشی تعدادی رکورد
SELECT 
	SalesOrderID
	,SalesOrderDetailID
	,CarrierTrackingNumber
	,OrderQty
FROM Sales.SalesOrderDetail
	WHERE ProductID = 710
GO
SELECT 
	OBJECT_NAME(ios.object_id) AS table_name
	,i.name AS index_name
	,ios.row_lock_count
	,ios.row_lock_wait_count
	,ios.row_lock_wait_in_ms
FROM sys.dm_db_index_operational_stats(DB_ID(),OBJECT_ID('Sales.SalesOrderDetail'),NULL,NULL) ios
INNER JOIN sys.indexes i
ON i.object_id = ios.object_id
AND i.index_id = ios.index_id
ORDER BY ios.range_scan_count DESC
GO
-----------------------
--Page Lock :هنگام دسترسی به ایندکس اگر تعدادی قفل به ازای صفحه ایجاد شود در این فیلد مشخص می شود
USE AdventureWorks2017
GO
SELECT 
	OBJECT_NAME(ios.object_id) AS table_name
	,i.name AS index_name
	,ios.page_lock_count
	,ios.page_lock_wait_count
	,ios.page_lock_wait_in_ms
FROM sys.dm_db_index_operational_stats(DB_ID(),OBJECT_ID('Sales.SalesOrderDetail'),NULL,NULL) ios
INNER JOIN sys.indexes i
ON i.object_id = ios.object_id
AND i.index_id = ios.index_id
ORDER BY ios.range_scan_count DESC
GO
-----------------------
--Lock Escalation : صعود قفل
--Lock Granularity سطوح قفل گذاری
USE AdventureWorks2017
GO
--به روز کردن تعدادی رکورد
UPDATE Sales.SalesOrderDetail SET 
	ProductID = ProductID
WHERE ProductID <= 712
GO
SELECT 
	OBJECT_NAME(ios.object_id) AS table_name
	,i.name AS index_name
	,ios.index_lock_promotion_attempt_count
	,ios.index_lock_promotion_count
FROM sys.dm_db_index_operational_stats(DB_ID(),OBJECT_ID('Sales.SalesOrderDetail'),NULL,NULL) ios
INNER JOIN sys.indexes i 
	ON i.object_id = ios.object_id AND i.index_id = ios.index_id
ORDER BY 
	ios.range_scan_count DESC
GO
