
--بررسی پروسیجرهای سیستمی

USE master
GO
--مشاهده پروسیجرهای سیستمی موجود در بانک اطلاعاتی 
SELECT * FROM sys.syscomments
SELECT OBJECT_NAME(id) FROM sys.syscomments
GO
--بررسی نحوه استفاده از آنها
USE Northwind
GO
SP_HELPFILE
GO
SP_HELP
GO

--------------------------------------

--DMV بررسی 
--توجه به آیکن
USE master
GO
SELECT * FROM ...
GO
--Instance مشاهده دیتابیس های موجود در یک 
SELECT * FROM  SYS.databases 
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SELECT * FROM SYS.database_files
---------------------
--DMF بررسی 
--توجه به آیکن
SELECT * FROM SYS...
GO
SELECT * FROM sys.dm_exec_input_buffer (XX, 0);
GO
---------------------
--ترکیب ویو و فانکشن
SELECT 
	es.session_id, ib.event_info   
FROM sys.dm_exec_sessions AS es  
CROSS APPLY sys.dm_exec_input_buffer(es.session_id, NULL) AS ib  
WHERE 
	es.session_id > 50;
GO
--Cross Apply بررسی اپراتور 
GO
-------------------------------------------------

--DBCC بررسی دستور 
/*
هستند DB_Owner , SysAdmin این دستورات اغلب نیازمند دسترسی 
*/
USE Northwind
GO
--راهمنما گرفتن 
DBCC HELP('SHRINKFILE')
GO
--Maintenance Statements
DBCC SHRINKFILE
DBCC DROPCLEANBUFFERS	
GO
--Informational Statements
DBCC INPUTBUFFER	
DBCC SQLPERF
GO
--Validation Statements
DBCC CHECKDB
DBCC CHECKIDENT
GO
--Miscellaneous Statements
DROP DATABASE IF EXISTS Northwind_Clone
GO
DBCC CLONEDATABASE (Northwind, Northwind_Clone)   
GO
