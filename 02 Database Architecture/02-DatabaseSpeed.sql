
--ایجاد یک بانک اطلاعاتی به همراه چند دیتا فایل و لاگ فایل
GO
USE master
GO
IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE Test01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test01
END
GO
--ساخت یک بانک اطلاعاتی با چند دیتا فایل
--ایجاد بانک اطلاعاتی
CREATE DATABASE DB_2017
 ON  PRIMARY
	( NAME = N'DB_2017_1', FILENAME = N'C:\Dump\DB_2017_1.mdf' , SIZE = 10MB , FILEGROWTH = 5MB ),
	( NAME = N'DB_2017_2', FILENAME = N'C:\Dump\DB_2017_2.ndf' , SIZE = 10MB , FILEGROWTH = 5MB ),
	( NAME = N'DB_2017_3', FILENAME = N'C:\Dump\DB_2017_3.ndf' , SIZE = 10MB , FILEGROWTH = 5MB)
 LOG ON
	( NAME = N'DB_2017_log', FILENAME = N'C:\Dump\DB_2017_log.ldf' , SIZE = 100MB , FILEGROWTH = 100MB)
GO 
USE DB_2017
GO
--مشاهده فایل های بانک اطلاعاتی
SP_HELPFILE
GO
SELECT 
	FILE_ID,name,physical_name,size,max_size,growth 
FROM sys.database_files
GO
--تنظیم نحوه رشد دیتا فایل ها
ALTER DATABASE DB_2017 MODIFY FILEGROUP [PRIMARY] AUTOGROW_ALL_FILES
GO
--بررسی تعداد دیتا فایل ها + ظرفیت آنها
SELECT
    DB_NAME() AS [db_name],
    mf.name AS logical_name,
    fg.name as [filegroup_name],
	CAST((mf.Size /128.0) AS DECIMAL(10,2)) AS [SizeMB],
    fg.is_autogrow_all_files
FROM sys.database_files AS mf
JOIN sys.filegroups AS fg
    ON mf.data_space_id = fg.data_space_id
GO

/*
TEMPDB
In the past, we have recommended customers to turn on trace flags 1117 and 1118 for applications that use tempdb heavily. However, adding these flags as startup parameters had an impact for the entire instance as opposed to just tempdb.

-T1117 – When growing a data file grow all files at the same time so they remain the same size, reducing allocation contention points.
-T1118 – When doing allocations for user tables always allocate full extents. Reducing contention of mixed extent allocations
In SQL Server 2016, the functionality provided by TF 1117 or 1118 will be automatically enabled for tempdb. This means, a customer will no longer have to enable these trace flags for a SQL Server 2016 instance.


User Databases
For User Databases, trace flags 1117 and 1118 have been replaced with new extensions in ALTER DATABASE commands. Use the ALTER DATABASE syntax to enable or disable the desired trace flag behavior at a database level.

Trace Flag 1118
Trace flag 1118 for user databases is replaced by a new ALTER DATABASE setting – MIXED_PAGE_ALLOCATION.
Default value of the MIXED_PAGE_ALLOCATION is OFF meaning allocations in the database will use uniform extents.
The setting is opposite in behavior of the trace flag (i.e. TF 1118 OFF and MIXED_PAGE_ALLOCATION ON provide the same behavior and vice-versa).
https://blogs.msdn.microsoft.com/sql_server_team/sql-server-2016-changes-in-default-behavior-for-autogrow-and-allocations-for-tempdb-and-user-databases/
*/
--------------------------------------------------------------------
--Instant File Initialization
--SQL Server 2016 تست بر روی 
GO
--Instant File Initialization غیر فعال کردن 
GO
--تهیه نسخه پشتیبان
BACKUP DATABASE AdventureworksDW2016CTP3 TO DISK ='E:\Backup\Aw1.bak'
	WITH STATS=1
GO
--Instant File Initialization فعال کردن 
--تهیه نسخه پشتیبان
BACKUP DATABASE AdventureworksDW2016CTP3 TO DISK ='E:\Backup\Aw2.bak' 
	WITH STATS=1
GO

/*
--تاثیر این ویژگی در 
Backup
Restore
File Growth
*/
/*

*/