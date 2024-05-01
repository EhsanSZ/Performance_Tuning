
--بررسی معماری منطقی و فیزیکی لاگ فایل 
GO
--ایجاد یک بانک اطلاعاتی جدید
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
--------------------------------------------------------------------
--مشاهده معماری منطقی
GO
--هاVLF مشاهده
--معماری منطقی لاگ فایل
DBCC LOGINFO
GO
/*
Status	:
	There are 2 possible values 0 and 2. 
	2 means that the VLF cannot be reused and 
	0 means that it is ready for re-use.
Parity	:
	There are 2 possible values 64 and 128.
CreateLSN	:
	This is the LSN when the VLF was created. 
	If the createLSN is 0, it means it was created 
	when the physical transaction log file was created.
*/
--------------------------------------------------------------------
--مشاهده معماری فیزیکی لاگ فایل
GO
USE MyDB2017
GO
--ایجاد یک جدول جدید
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	C1 INT IDENTITY PRIMARY KEY,
	C2 NVARCHAR(10),
	C3 NVARCHAR(10)
)
GO
INSERT TestTable(C2,C3) VALUES (N'T1',N'T11')
INSERT TestTable(C2,C3) VALUES (N'T2',N'T22')
GO
SELECT * FROM TestTable
GO
--مشاهده معماری فیزیکی
ALTER DATABASE MyDB2017 SET RECOVERY SIMPLE
GO
CHECKPOINT
GO
--مشاهده محتوای لاگ رکوردها
SELECT * FROM SYS.fn_dblog(NULL,NULL)
GO
--ایجاد یک رکورد جدید
INSERT TestTable(C2,C3) VALUES (N'T33',N'T33')
GO
--مشاهده محتوای لاگ رکوردها
--Online Log File
SELECT * FROM SYS.fn_dblog(NULL,NULL)
GO
--ایجاد یک رکورد جدید
INSERT TestTable(C2,C3) VALUES (N'T4',N'T44')
GO
--رکورد کجا درج شده است
SELECT
	[Transaction ID], [Current LSN], [Transaction Name], 
	[Operation],  [Context],[AllocUnitName],[Begin Time],
	[End Time], [Transaction SID],[Num Elements] ,
	[RowLog Contents 0],[RowLog Contents 1],
	[RowLog Contents 2],[RowLog Contents 3]
FROM fn_dblog (NULL, NULL)
 WHERE [Transaction ID] IN 
	(
		SELECT 
			[Transaction ID] 
		FROM fn_dblog (null,null) 
		WHERE [Transaction Name] = 'INSERT'
	)
GO
--مشاهده لاگ رکوردهای موجود در یک لاگ بکاپ
--دارای 68 پارامتر می باشد
SELECT  * FROM fn_dump_dblog
(
	NULL,NULL,'DISK',1,'C:\Temp\MyDB2017_log.trn'
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	,NULL,NULL,NULL,NULL
)
GO
--------------------------------------------------------------------
--SQL SERVER 2017 قابلیت های جدید اضافه شده در لاگ فایل در 
SELECT 
	* 
FROM sys.dm_db_log_info(DEFAULT)
GO
SELECT TOP 100 
	DB_NAME(database_id) AS "Database Name",file_id,
	vlf_size_mb,vlf_sequence_number, 
	vlf_active, vlf_status
FROM sys.dm_db_log_info(DEFAULT)
ORDER BY vlf_sequence_number desc
GO
--آنها بیش از 100 عدد استVLF مشاهده بانک اطلاعاتی هایی که تعداد
--Log Fragmentation
SELECT 
	NAME,COUNT(l.database_id) as 'VLF_Count' 
FROM sys.databases s
CROSS APPLY sys.dm_db_log_info(s.database_id) l
GROUP BY NAME
HAVING COUNT(l.database_id)> 100
GO
-------------------------------
--خلاصه ای از آمار کارهای انجام شده به ازای لاگ فایل
--2017 ارائه شده از نسخه 
SELECT 
	* 
FROM sys.dm_db_log_stats(DB_ID(N'MyDB2017'))
GO
--مشاهده خلاصه آمار به ازای لاگ فایل بانک های اطلاعاتی
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
GO

