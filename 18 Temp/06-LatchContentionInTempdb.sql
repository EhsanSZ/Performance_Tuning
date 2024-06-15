
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
--کار می کشد Tempdb که به شدت ازSP ایجاد یک 
CREATE PROCEDURE usp_temp_table
AS 
CREATE TABLE #tmpTable
(
	c1 INT,
	c2 INT,
	c3 CHAR(5000)
) 
CREATE UNIQUE CLUSTERED INDEX cix_c1 ON #tmptable ( c1 ) 
DECLARE @i INT = 0 
WHILE ( @i < 10 ) 
BEGIN
	INSERT INTO #tmpTable ( c1, c2, c3 )
		VALUES ( @i, @i + 100, 'NikAmooz' ) 
	SET @i += 1 
END 
GO
--SP اول در این SP فراخوانی
CREATE PROCEDURE usp_loop_temp_table
AS 
SET NOCOUNT ON 
DECLARE @i INT = 0 
WHILE ( @i < 100 )
BEGIN
	EXEC usp_temp_table 
	SET @i += 1 
END 
go
--SQLQueryStress اجرا با برنامه 
/*
Number of Iterations : 1
Number of Threads : 100
*/
EXEC usp_loop_temp_table
GO
--------------------------------------------------------------------
/*
GAM: (Page ID - 2) % 511232
SGAM: (Page ID - 3) % 511232
PFS: (Page ID - 1) % 8088
*/
SELECT 
	session_id,
	wait_type,
	wait_duration_ms,
	blocking_session_id,
	resource_description,
	ResourceType =
		CASE
			WHEN Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 1 % 8088 = 0 Then 'Is PFS Page'
			WHEN Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 2 % 511232 = 0 Then 'Is GAM Page'
			WHEN Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 3 % 511232 = 0 Then 'Is SGAM Page'
			ELSE 'Is Not PFS, GAM, or SGAM page' 
		END
FROM sys.dm_os_waiting_tasks
WHERE
	wait_type Like 'PAGE%LATCH_%' AND
	resource_description Like '2:%'
GO
--------------------------------------------------------------------
--Tempdb افزایش تعداد دیتا فایل های مربوط به 
USE tempdb
GO
--بررسی فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
GO
USE master
GO
ALTER DATABASE tempdb MODIFY FILE (NAME=tempdev,SIZE=512MB,FILEGROWTH=100MB)
ALTER DATABASE tempdb ADD FILE (NAME=tempdev2,SIZE=512MB,FILEGROWTH=100MB,FILENAME='E:\Database\tempdev2.ndf') 
ALTER DATABASE tempdb ADD FILE (NAME=tempdev3,SIZE=512MB,FILEGROWTH=100MB,FILENAME='E:\Database\tempdev3.ndf')
ALTER DATABASE tempdb ADD FILE (NAME=tempdev4,SIZE=512MB,FILEGROWTH=100MB,FILENAME='E:\Database\tempdev4.ndf')
ALTER DATABASE tempdb ADD FILE (NAME=tempdev5,SIZE=512MB,FILEGROWTH=100MB,FILENAME='E:\Database\tempdev5.ndf') 
ALTER DATABASE tempdb ADD FILE (NAME=tempdev6,SIZE=512MB,FILEGROWTH=100MB,FILENAME='E:\Database\tempdev6.ndf')
ALTER DATABASE tempdb ADD FILE (NAME=tempdev7,SIZE=512MB,FILEGROWTH=100MB,FILENAME='E:\Database\tempdev7.ndf')
ALTER DATABASE tempdb ADD FILE (NAME=tempdev8,SIZE=512MB,FILEGROWTH=100MB,FILENAME='E:\Database\tempdev8.ndf')
GO
--ایجاد فایل های زمان بر است
USE tempdb
GO
--بررسی فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
GO
--Restat SQL Server Service
--اگر اندازه ها یکسان نبودن
GO
--------------------------------------------------------------------
--SQLQueryStress اجرا با برنامه 
/*
Number of Iterations : 1
Number of Threads : 100
*/
EXEC usp_loop_temp_table
GO
/*
GAM: (Page ID - 2) % 511232
SGAM: (Page ID - 3) % 511232
PFS: (Page ID - 1) % 8088
*/
SELECT 
	session_id,
	wait_type,
	wait_duration_ms,
	blocking_session_id,
	resource_description,
	ResourceType =
		CASE
			WHEN Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 1 % 8088 = 0 Then 'Is PFS Page'
			WHEN Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 2 % 511232 = 0 Then 'Is GAM Page'
			WHEN Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 3 % 511232 = 0 Then 'Is SGAM Page'
			ELSE 'Is Not PFS, GAM, or SGAM page' 
		END
FROM sys.dm_os_waiting_tasks
WHERE
	wait_type Like 'PAGE%LATCH_%' AND
	resource_description Like '2:%'
GO
--بررسی ظرفیت فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
GO
--------------------------------------------------------------------
--Single User Mode (****)
USE tempdb
GO
--خالی کردن محتوای دیتا فایل های
DBCC SHRINKFILE (N'tempdev2' , EMPTYFILE)
DBCC SHRINKFILE (N'tempdev3' , EMPTYFILE)
DBCC SHRINKFILE (N'tempdev4' , EMPTYFILE)
DBCC SHRINKFILE (N'tempdev5' , EMPTYFILE)
DBCC SHRINKFILE (N'tempdev6' , EMPTYFILE)
DBCC SHRINKFILE (N'tempdev7' , EMPTYFILE)
DBCC SHRINKFILE (N'tempdev8' , EMPTYFILE)
GO
USE master
GO
ALTER DATABASE tempdb  REMOVE FILE tempdev2
ALTER DATABASE tempdb  REMOVE FILE tempdev3
ALTER DATABASE tempdb  REMOVE FILE tempdev4
ALTER DATABASE tempdb  REMOVE FILE tempdev5
ALTER DATABASE tempdb  REMOVE FILE tempdev6
ALTER DATABASE tempdb  REMOVE FILE tempdev7
ALTER DATABASE tempdb  REMOVE FILE tempdev8
ALTER DATABASE tempdb MODIFY FILE (NAME=tempdev,SIZE=10MB,FILEGROWTH=100MB) ;
GO

use tempdb
SP_HELPFILE
GO
--------------------------------------------------------------------
--Script to Check TempDB Speed
SELECT 
	files.physical_name, files.name, 
	stats.num_of_writes, (1.0 * stats.io_stall_write_ms / stats.num_of_writes) AS avg_write_stall_ms,
	stats.num_of_reads, (1.0 * stats.io_stall_read_ms / stats.num_of_reads) AS avg_read_stall_ms
FROM sys.dm_io_virtual_file_stats(2, NULL) as stats
INNER JOIN master.sys.master_files AS files 
  ON stats.database_id = files.database_id
  AND stats.file_id = files.file_id
WHERE files.type_desc = 'ROWS'
GO