
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO
--------------------------------------------------------------------
/*
و قسمت های مربوط به آنPlan Cache بررسی 
*/
USE MyDB2017
GO
--SQL SERVER مشاهده قسمت هاي مختلف حافظه تخصيص يافته به 
DBCC MemoryStatus 
GO
/*
 قسمت های مختلف پلن کش را کش استور می نامند 
 Procedure Cache|Plan Cache
 CACHESTORE_OBJCP : Object Plans * پروسیجرها* توابع 
 CACHESTORE_SQLCP : SQL Plans *Ad-hoc کوئری های 
 CACHESTORE_PHDR  : Bound Trees * درخت های ایجاد شده در مرحله بهینه سازی
 CACHESTORE_XPROC : Extended Stored Procedures
*/
GO
--مشاهده اندازه مربوط به کش استورها
SELECT
	 type as [Cache Store], SUM(pages_in_bytes) / 1024.0 AS [Size in KB]
FROM sys.dm_os_memory_objects
WHERE TYPE IN 
(
	'MEMOBJ_CACHESTORESQLCP','MEMOBJ_CACHESTOREOBJCP'
	,'MEMOBJ_CACHESTOREXPROC','MEMOBJ_SQLMGR'
)
GROUP BY type
GO
--------------------------------------------------------------------
--مشاهده كوئري هايي كه كش شده اند
SELECT * FROM sys.syscacheobjects 
GO
--مشاهده كوئري هايي كه كش شده اند
SELECT 
	C.cacheobjtype,C.objtype,C.sql,C.sqlbytes 
FROM sys.syscacheobjects C
GO
/*
CacheObjectType : 
	Compiled Plan
	Compiled Plan Stub
	Parse Tree
	Extended Proc
	CLR Compiled Func
	CLR Compiled Proc
*/
--چه تعداد كوئري كش شده اند
SELECT COUNT(C.objid) FROM sys.syscacheobjects C
GO
--چه مقدار حافظه به متن كوئري هايي كه كش شده اند تخصيص يافته است 
SELECT SUM(C.sqlbytes + 0.00) FROM sys.syscacheobjects C
GO
--مشاهده كوئري هايي كه كش شده اند
--هر كوئري يك هندل دارد
--اين هندل به صورت هش شده مي باشد
SELECT * FROM sys.dm_exec_cached_plans 
GO
--مشاهده سورس كوئري هايي كه كش شده اند
SELECT CP.cacheobjtype ,CP.plan_handle,CP.size_in_bytes,ST.text
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
GO
--مقدار حافظه تخصيص يافته در كش به ازاي كوئري ها كه شامل ركوردهاي موجود در حافظه
SELECT  SUM(CP.size_in_bytes + 0.00)/1024/1024 FROM sys.dm_exec_cached_plans CP
GO
--مشاهده سورس كوئري هايي كه كش شده اند
--به همراه پلت اجرايي 
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) 
GO
--------------------------------------------------------------------
DBCC FREEPROCCACHE --پاك كردن كش مربوط به پروسيجرهاو .... به ازاي كليه بانك هاي اطلاعاتي مي باشد
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
GO
--محتواي كش نمايش داده شود
SELECT * FROM sys.syscacheobjects 
--------------------------------------------------------------------
--بررسي اطلاعات موجود در كش
USE Northwind
GO
DBCC FREEPROCCACHE --پاك كردن كش مربوط به پروسيجرهاو .... به ازاي كليه بانك هاي اطلاعاتي مي باشد
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO
SELECT * FROM Orders
GO
--كوئري كه از جدول سفارش ها گرفتم در كش موجود است
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
--كوئري كه از جدول سفارش ها گرفتم در كش موجود است
SELECT C.sql,C.sqlbytes FROM sys.syscacheobjects C
GO
--------------------------------------------------------------------
DBCC FREEPROCCACHE --پاك كردن كش مربوط به پروسيجرهاو .... به ازاي كليه بانك هاي اطلاعاتي مي باشد
GO
--محتواي كش نمايش داده شود
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
SELECT * FROM Orders WHERE ShipCountry='uk'
GO
SELECT * FROM Orders WHERE ShipCountry='Uk'
GO
SELECT * FROM orders WHERE ShipCountry='uk'
GO
SELECT * FROM Orders WHERE  ShipCountry='uk' --
GO
SELECT * FROM Orders WHERE  ShipCountry='usa'
GO
--مشاهده پلن کش
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
DBCC FREEPROCCACHE --پاك كردن كش مربوط به پروسيجرهاو .... به ازاي كليه بانك هاي اطلاعاتي مي باشد
GO
--------------------------------------------------------------------
--در پلن كشDaynamic SQL تاثير استفاده از 
USE Northwind
GO
DBCC FREEPROCCACHE 
GO
--مشاهده پلن کش
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
EXEC sp_executesql N'SELECT * FROM Orders WHERE OrderID=@OrderID',
	N'@OrderID INT', @OrderID=10253
GO
EXEC sp_executesql N'SELECT * FROM Orders WHERE OrderID=@OrderID',
	N'@OrderID INT', @OrderID=10254
GO
EXEC sp_executesql N'SELECT * FROM Orders WHERE OrderID=@OrderID',
	N'@OrderID INT', @OrderID=10255
--مشاهده پلن کش
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
--متن کوئری با حروف کوچک نوشته شده است
EXEC sp_executesql N'select * FROM Orders where OrderID=@OrderID',
	N'@OrderID INT', @OrderID=10255
GO
--مشاهده پلن کش
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
--------------------------------------------------------------------
--در پلن كشStored Proccedure تاثير استفاده از 
GO
--بررسی جهت وجود پروسیجر
IF  OBJECT_ID('usp_GetOrders')>0
	DROP PROCEDURE usp_GetOrders
GO
CREATE PROCEDURE usp_GetOrders(@OrderID INT)
AS
	SELECT * FROM Orders
		WHERE OrderID=@OrderID
GO
DBCC FREEPROCCACHE
GO
--مشاهده پلن کش
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
--فراخوانی و اجرای پروسیجر ها
EXEC usp_GetOrders 10248
EXEC usp_GetOrders 10254
EXEC usp_GetOrders 10254
EXEC USP_GetOrders 10255
GO
--مشاهده پلن کش
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
--------------------------------------------------------------------
/*
اجرای برنامه دات نت
*/
--------------------------------------------------------------------
/*
Ad-Hoc بهینه سازی پلن برای کوئری های 
--optimize for ad hoc workloads بررسی تاثیر
*/
USE master
GO
SP_CONFIGURE 'show advanced options',1
GO
RECONFIGURE
GO
SP_CONFIGURE 'optimize for ad hoc workloads',1
GO
RECONFIGURE
GO
DBCC FREEPROCCACHE 
GO
USE Northwind
GO
--محتواي كش نمايش داده شود
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,usecounts
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
			WHERE ST.text LIKE '%Orders%' 
GO
SELECT * FROM Orders WHERE ShipCountry='uk'
GO
--محتواي كش نمايش داده شود
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,usecounts
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
			WHERE ST.text LIKE '%Orders%' 
GO
SELECT * FROM Orders WHERE ShipCountry='UK'
GO
--محتواي كش نمايش داده شود
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,usecounts
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
			WHERE ST.text LIKE '%Orders%' 
GO
--Dynamic SQL
EXEC sp_executesql N'select * FROM Orders where OrderID=@OrderID',
	N'@OrderID INT', @OrderID=10255
GO
--مشاهده پلن کش
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
--فراخوانی و اجرای پروسیجر 
EXEC usp_GetOrders 10248
GO
--مشاهده پلن کش
SELECT CP.cacheobjtype ,CP.size_in_bytes,ST.text,cp.usecounts,QP.query_plan
	FROM sys.dm_exec_cached_plans CP
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS ST
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QP
			WHERE ST.text LIKE '%Orders%'
GO
SP_CONFIGURE 'optimize for ad hoc workloads',0
GO
RECONFIGURE
GO
--------------------------------------------------------------------
--بررسی مثال در ویژوال استادیو
GO
--------------------------------------------------------------------------------------------------------
