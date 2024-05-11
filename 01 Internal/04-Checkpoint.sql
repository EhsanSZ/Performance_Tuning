
--Checkpoint بررسی انواع 
GO
--Manual Checkpoint (دستی Checkpoint)
--به ازای یک بانک اطلاعاتی خاص رخ می دهد
USE MyDB2017
GO
CHECKPOINT
GO
CHECKPOINT 5
GO
---------------------
--Automatic Checkpoint (اتوماتیک Checkpoint)
SP_CONFIGURE 'recovery interval (min)'
GO
SP_CONFIGURE 'recovery interval (min)', 15
GO
RECONFIGURE
---------------------
--Indirect Checkpoint (غیر مستقیم Checkpoint)
/*
استفاده نمی شود Automatic Checkpoint در این حالت از 
به بعد SQL Server 2012 ارائه از 
SSMS بررسی در 

ALTER DATABASE database_name SET 
	TARGET_RECOVERY_TIME = target_recovery_time { SECONDS | MINUTES}
*/
ALTER DATABASE MyDB2017 SET 
	TARGET_RECOVERY_TIME = 50 SECONDS 
GO
---------------------
--Internal Checkpoint (داخلی Checkpoint)
/*
غیر قابل کنترل توسط کاربر می باشدCheckpoint این نوع
می تواند رخ دهدCheckpoint در حالت های زیر این نوع 

Some database files have been modified (removed or added by T-SQL command ALTER DATABASE)
Database backup is in progress
Database snapshot is being created
Shutdown operation occurred on all databases except when Shutdown is not clean (with NOWAIT)
Recovery model has been changed from Full or Bulk-Logged to Simple
Database log is 70% full (applies only to Simple recovery model)
Minimally logged operation executed (applies only to Bulk-Logged recovery model)
*/
