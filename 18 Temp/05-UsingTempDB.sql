
--Tempdb مثالی جهت بررسی استفاده خودکار از بانک اطلاعاتی
GO
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('Temp_Test')>0
BEGIN
	ALTER DATABASE Temp_Test SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Temp_Test
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE Temp_Test
GO
USE Temp_Test
GO
--------------------------------------------------------------------
--ایجاد جدول تستی
IF OBJECT_ID('Test')>0
	DROP TABLE Test
GO
CREATE TABLE Test    
( 
	Id INT IDENTITY(1, 1) , 
	[Name] CHAR(900) DEFAULT N'NikAmooz'
)          
GO   
--درج تعدادی رکورد تستی
INSERT INTO Test DEFAULT VALUES 
GO 100
--ایجاد کلاستر ایندکس به ازای جدول
CREATE CLUSTERED INDEX IX_Test_Name ON Test(Name ASC)
GO
--------------------------------------------------------------------
SET STATISTICS IO ON 
--شود Tempdb انجام عملیاتی که منجر به استفاده از 
--Show Execution Plan
UPDATE Test SET [Name] = NEWID()
GO
--TempDb جاری در Session صفحات استفاده شده
SELECT 
	internal_objects_alloc_page_count,
	internal_objects_dealloc_page_count
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO
--به روزرسانی جدول
UPDATE Test SET [Name] = NEWID()
GO
--TempDb جاری در Session صفحات استفاده شده
SELECT 
	internal_objects_alloc_page_count,
	internal_objects_dealloc_page_count
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO
--------------------------------------------------------------------
--بررسی انواع صفحات تخصیص داده شده به 
USE tempdb
GO
SELECT
	SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
	SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
	SUM (version_store_reserved_page_count)*8  as version_store_kb,
	SUM (unallocated_extent_page_count)*8 as freespace_kb,
	SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage
--------------------------------------------------------------------
USE tempdb
GO
--هستندTempdb استخراج کوئری ها و کاربرانی که در حال استفاده از 
SELECT ssu.session_id, 
(ssu.internal_objects_alloc_page_count + sess_alloc) as allocated, 
(ssu.internal_objects_dealloc_page_count + sess_dealloc) as deallocated 
 , stm.TEXT
FROM 
		sys.dm_db_session_space_usage as ssu,  
        sys.dm_exec_requests req
        CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS stm ,
(select session_id,  
   sum(internal_objects_alloc_page_count) as sess_alloc, 
   sum (internal_objects_dealloc_page_count) as sess_dealloc 
   from sys.dm_db_task_space_usage group by session_id) as tsk 
where ssu.session_id = tsk.session_id 
and ssu.session_id >50 
AND SSU.SESSION_ID<>@@SPID
and ssu.session_id = req.session_id 
and ssu.database_id = 2 
order by allocated DESC
/*
UPDATE Test SET [Name] = NEWID()
GO 1000
*/