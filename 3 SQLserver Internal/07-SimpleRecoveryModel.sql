
--Simple Recovery Model بررسی 
USE master
GO
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
--Recovery Model تغییر وضعیت 
ALTER DATABASE MyDB2017 SET RECOVERY SIMPLE
GO
--Recovery Model مشاهده وضعیت
SELECT 
	database_id,name,recovery_model_desc 
FROM SYS.databases
WHERE name='MyDB2017'
GO
GO
--Log File مشاهده وضعیت استفاده از 
--چندین مرتبه اجرا شود
DBCC SQLPERF('LOGSPACE')
GO
SELECT 
  [database]      = d.name, 
  [recovery]      = ls.recovery_model, 
  [vlf_count]     = ls.total_vlf_count, 
  [active_vlfs]   = ls.active_vlf_count,
  [vlf_size]      = ls.current_vlf_size_mb,
  [active_log_%]  = CONVERT(decimal(5,2), 
                    100.0*ls.active_log_size_mb/ls.total_log_size_mb)
FROM sys.databases AS d
CROSS APPLY sys.dm_db_log_stats(d.database_id) AS ls
WHERE 
	D.name='MyDB2017'
GO
--ایجاد یک جدول جدید
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	C1 INT IDENTITY PRIMARY KEY,
	C2 CHAR(4000),
	C3 NVARCHAR(4000)
)
GO
--SQLQueryStress 10000, 100
INSERT TestTable(C2,C3) VALUES (N'T1',N'T11')
GO
--استفاده از کانترهای زیر
/*
MSSQLSERVER: Databases :Log File Size(KB)
MSSQLSERVER: Databases :Log File Used Size(KB)
MSSQLSERVER: Databases :Percent Log Used
*/
GO
