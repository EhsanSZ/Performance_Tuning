
--SQL Server لاگ 
USE MASTER
GO
EXEC xp_readerrorlog
GO
EXEC xp_readerrorlog 0, 1, N'Logging SQL Server messages in file'
GO
--SQLServerManager14.msc عوض کردن مسیر از طریق برنامه 
GO
--پاک کردن فایل های مربوط به خطا
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', REG_DWORD, 6
GO
-- و پاک کردن فایل ها Object Explorer کلیک راست در 
GO
