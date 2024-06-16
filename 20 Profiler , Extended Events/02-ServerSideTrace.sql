
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
--Server Side Trace ساخت 
SELECT * FROM sys.traces
GO
SP_CONFIGURE 'default trace enabled'
GO
--Trace File نمايش محتويات يك 
SELECT * FROM fn_trace_gettable ('D:\Dump\Trace\T2.trc',DEFAULT) 
	ORDER BY StartTime DESC
GO
--------------------------------------------------------------------
--Trace تنظیم وضعیت 
/*
sp_trace_setstatus [ @traceid = ] trace_id , [ @status = ] status  
0	Stops the specified trace.
1	Starts the specified trace.
2	Closes the specified trace and deletes its definition from the server.
https://msdn.microsoft.com/en-us/library/ms176034.aspx
*/
GO
sp_trace_setstatus @traceid=2,@status=0
sp_trace_setstatus @traceid=2,@status=2
GO
--------------------------------------------------------------------
--Trace اجرای همیشگی 
USE master
GO
EXEC sp_procoption 
@ProcName='USP1',
@OptionName='startup',
@OptionValue='off'
GO
--With Job
sp_configure 'show advanced options',1
reconfigure
sp_configure 'scan for startup procs' , 0
reconfigure

SELECT name,create_date,modify_date
FROM sys.procedures
WHERE OBJECTPROPERTY(OBJECT_ID, 'ExecIsStartup') = 1
GO
SELECT name,create_date,modify_date
FROM sys.procedures
WHERE is_auto_executed = 1
