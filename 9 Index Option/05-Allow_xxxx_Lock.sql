
--Allow_Row_Lock,Allow_Page_Lock بررسی استفاده از  
GO
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
--ایجاد یک جدول جدید
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	C1 INT IDENTITY ,
	C2 CHAR(900),
	C3 DATETIME DEFAULT GETDATE()
)
GO
--درج تعدادی رکورد در جدول
INSERT TestTable(C2) VALUES (N'T1')
GO 10000
--مشاهده حجم رکوردهای موجود در جدول
SP_SPACEUSED TestTable
GO
--------------------------------------------------------------------
--ساخت ایندکس کلاستر به صورت عادی
GO
BEGIN TRANSACTION
GO
--Clustered Index ایجد یک 
CREATE  INDEX IX_C2 ON TestTable(C1)
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
	WHERE  dtl.request_session_id = @@SPID ;
/*
Normal Index : Lock Count : 82
*/
GO
ROLLBACK TRANSACTION
-----------------------------------
--ALLOW_ROW_LOCKS ساخت ایندکس کلاستر به صورت 
GO
BEGIN TRANSACTION
GO
--Clustered Index ایجد یک 
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON TestTable(C1)
	WITH (ALLOW_ROW_LOCKS=ON)
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
	WHERE  dtl.request_session_id = @@SPID ;
GO
/*
ALLOW_ROW_LOCKS : Lock Count : 636
*/
GO
ROLLBACK TRANSACTION
GO
-----------------------------------
--ALLOW_PAGE_LOCKS ساخت ایندکس کلاستر به صورت 
GO
BEGIN TRANSACTION
GO
--Clustered Index ایجد یک 
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON TestTable(C1)
	WITH (ALLOW_PAGE_LOCKS=ON)
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
	WHERE  dtl.request_session_id = @@SPID ;
GO
/*
ALLOW_PAGE_LOCKS Lock Count : 581
*/
GO
ROLLBACK TRANSACTION
GO
CHECKPOINT
--------------------------------------------------------------------
--مقایسه هر کدام از روش های مورد استفاده 
GO
/*
ساخت ایندکس کلاستر به صورت عادی
Normal Index Lock Count : 82
*/
GO
/*
ALLOW_ROW_LOCKS ساخت ایندکس کلاستر به صورت 
ALLOW_ROW_LOCKS : Lock Count : 636
*/
GO
/*
ALLOW_PAGE_LOCKS ساخت ایندکس کلاستر به صورت 
ALLOW_PAGE_LOCKS Lock Count : 581
*/