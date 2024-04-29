
--Main File
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('SQL2017_Demo')>0
BEGIN
	ALTER DATABASE SQL2017_Demo SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE SQL2017_Demo
END
GO
--------------------------------------------------------------------
--ایجاد بانک اطلاعاتی
CREATE DATABASE SQL2017_Demo
 ON  PRIMARY
( 
    NAME = N'SQL2017_Demo', 
    FILENAME = N'e:\Dump\SQL2017_Demo.mdf', 
    SIZE = 5120KB, 
    FILEGROWTH = 1024KB 
 )
 LOG ON 
 ( 
    NAME = N'SQL2017_Demo_log', 
    FILENAME = N'e:\Dump\SQL2017_Demo_log.ldf', 
    SIZE = 1024KB, 
    FILEGROWTH = 10%
 )
GO
--MEMORY_OPTIMIZED_DATA اضافه شدن فایل گروه از نوع 
ALTER DATABASE SQL2017_Demo 
    ADD FILEGROUP MemFG CONTAINS MEMORY_OPTIMIZED_DATA 
GO
--اضافه کردن فایل به فایل گروه مورد نظر
ALTER DATABASE SQL2017_Demo ADD FILE
	( 
		NAME = MemFG_File1,
		FILENAME = N'e:\Dump\MemFG_File1'--مسیر مورد نظر بررسی شود
	) 
TO FILEGROUP MemFG
GO
--Object Explorer بررسی نحوه ایجاد بانک اطلاعاتی در 
GO
--------------------------------------------------------------------
USE SQL2017_Demo
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SELECT 
	name,type_desc,physical_name 
FROM SYS.database_files
GO
--Run Window Explorer
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SELECT * FROM SYS.filegroups
GO
-------------------------------------------------------------------- 
--بررسی جهت وجود جدول
IF OBJECT_ID('MemOptTable1')>0
	DROP TABLE MemOptTable1
GO
--Memory Optimized Table  ایجاد یک جدول از نوع
--داده های مربوط به جدول در دیسک ثبت می گردد
--در صورت ذخیره محتوای جدول در دیسک باید حتما کلید اصلی موجود باشد
CREATE TABLE MemOptTable1
(
    ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
--Memory Optimized Table  مشاهده لیست جداول از نوع
SELECT 
	name,type_desc,durability_desc,Is_memory_Optimized 
FROM sys.tables
	WHERE Is_memory_Optimized = 1
GO
--------------------------------------------------------------------
--بررسی جهت وجود جدول
IF OBJECT_ID('MemOptTable2')>0
	DROP TABLE MemOptTable2
GO
--Memory Optimized Table  ایجاد یک جدول از نوع
--داده های مربوط به جدول در دیسک ثبت نمی گردد
CREATE TABLE MemOptTable2
(
    ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)
GO
--Memory Optimized Table  مشاهده لیست جداول از نوع
SELECT 
	name,type_desc,durability_desc,Is_memory_Optimized 
FROM sys.tables
	WHERE Is_memory_Optimized = 1
GO
--------------------------------------------------------------------
--ایجاد شده به ازای جدول DLL مشاهده 
SELECT
	OBJECT_ID('MemOptTable1') AS MemOptTable1_ObjectID,
	OBJECT_ID('MemOptTable2') AS MemOptTable2_ObjectID
GO
SELECT 
	name,description 
FROM sys.dm_os_loaded_modules
WHERE name LIKE '%XTP%'
GO
--بررسی دیتا فایل و دلتا فایل ها + ظرفیت هر کدام از آنها
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Log File در Memory Optimized Table ثبت لاگ کمتر به ازای
USE SQL2017_Demo
GO
--Disk Based ایجاد یک جدول 
CREATE TABLE TestTable_DiskBased
(
	Col1 INT NOT NULL PRIMARY KEY,
	Col2 VARCHAR(100) NOT NULL INDEX idx_Col2 NONCLUSTERED,
	Col3 VARCHAR(100) NOT NULL
)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX TestTable_DiskBased
GO
--Disk Based درج 10000 رکورد تستی در جدول 
DECLARE @i INT = 0
BEGIN TRANSACTION
WHILE (@i < 10000)
BEGIN
	INSERT INTO TestTable_DiskBased VALUES (@i, @i, @i)
 
	SET @i += 1 
END
COMMIT
GO
--ثبت تعداد زیادی لاگ در لاگ فایل به ازای ایندکس ها
--Log Record Length توجه به فیلد
SELECT * FROM sys.fn_dblog(NULL, NULL)
WHERE PartitionId IN
(
	SELECT partition_id FROM sys.partitions
	WHERE object_id = OBJECT_ID('TestTable_DiskBased')
)
GO
--Memory Optimized tableایجاد جدول از نوع  
CREATE TABLE TestTable_MemoryOptimized
(
	Col1 INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 16384),
	Col2 VARCHAR(100) COLLATE Latin1_General_100_Bin2 NOT NULL INDEX idx_Col2,
	Col3 VARCHAR(100) COLLATE Latin1_General_100_Bin2 NOT NULL INDEX idx_Col3
) WITH
(
	MEMORY_OPTIMIZED = ON, 
	DURABILITY = SCHEMA_AND_DATA
)
GO
--به ایندکس های جدول دقت کنید
GO
--Memory Optimized table درج 10000 رکورد تستی در جدول 
DECLARE @i INT = 0
BEGIN TRANSACTION
WHILE (@i < 10000)
BEGIN
	INSERT INTO TestTable_MemoryOptimized VALUES (@i, @i, @i)
 
	SET @i += 1 
END
COMMIT
GO
--Memory Optimized table بررسی لاگ فایل مربوط به 
SELECT * FROM sys.fn_dblog(NULL, NULL)
WHERE Operation='LOP_HK'
ORDER BY [Current LSN] DESC
GO
--Memory Optimized table بررسی لاگ مخصوص 
SELECT 
	[current lsn], [transaction id], operation,
	operation_desc, tx_end_timestamp, total_size
	--object_name(table_id) AS TableName
FROM sys.fn_dblog_xtp(null, null)
WHERE [Current LSN] = '00000032:000002c6:0001'
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Memory Optimized Table در Lock بررسی 
GO
--Disk Based  انجام عملیات در یک جدول از نوع
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('DiskTable')>0
	DROP TABLE DiskTable
GO
--Disk Based  ایجاد یک جدول از نوع
CREATE TABLE DiskTable
(
    ID INT NOT NULL PRIMARY KEY ,
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) 
GO
BEGIN TRANSACTION
--درج رکورد در جدول
INSERT INTO DiskTable(ID,FullName,DateAdded)
	VALUES (1,N'علیرضا طاهری',GETDATE())
--مشاهده لاک های مربوط به جدول
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
ROLLBACK
GO
--------------------------------------------------------------------
--Memory Optimized Table  انجام عملیات در یک جدول از نوع
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('MemOptTable')>0
	DROP TABLE MemOptTable
GO
--Memory Optimized Table  ایجاد یک جدول از نوع
CREATE TABLE MemOptTable
(
    ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
BEGIN TRANSACTION
--درج رکورد در جدول
INSERT INTO MemOptTable(ID,FullName,DateAdded)
	VALUES (1,N'علیرضا طاهری',GETDATE())
--مشاهده لاک های مربوط به جدول
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
ROLLBACK
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Hash Index بررسی
--بررسی جهت وجود جدول
IF OBJECT_ID('MemOptTable')>0
	DROP TABLE MemOptTable
GO
--Memory Optimized Table  ایجاد یک جدول از نوع
CREATE TABLE MemOptTable
(
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
--درج تعدادی رکورد در بانک اطلاعاتی
INSERT INTO MemOptTable(FullName,DateAdded)
	VALUES ('FullName',GETDATE())
GO 5000
--بررسی تعداد رکوردهای درج شده
SELECT COUNT(ID) FROM MemOptTable
GO
--مشاهده پلن اجرایی کوئری
--Show Estimate Execution Plan & Actual Execution Plan
SELECT * FROM MemOptTable
	WHERE ID=123
GO
--مشاهده پلن اجرایی کوئری
--Show Estimate Execution Plan & Actual Execution Plan
SELECT * FROM MemOptTable
	WHERE ID BETWEEN 123 AND 124
GO
SELECT * FROM MemOptTable
	WHERE ID =123 OR ID=124
GO
--------------------------------------------------------------------
--ایجاد چند هش ایندکس
--بررسی جهت وجود جدول
IF OBJECT_ID('MemOptTable2')>0
	DROP TABLE MemOptTable2
GO
--COLLATE Latin1_General_100_BIN2 
--Memory Optimized Table  ایجاد یک جدول از نوع
CREATE TABLE MemOptTable2
(
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
	NationalCode CHAR(10) NOT NULL INDEX IX_NationalCode NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
--------------------------------------------------------------------
--Disk Based مقایسه هش ایندکس با ایندکس کلاستر جداول 
IF OBJECT_ID('DiskTable')>0
	DROP TABLE DiskTable
GO
--Disk Based  ایجاد یک جدول از نوع
CREATE TABLE DiskTable
(
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY ,
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) 
GO
INSERT INTO DiskTable(FullName,DateAdded)
	VALUES (N'FullName',GETDATE())
GO 5000

SET STATISTICS IO ON 
--مشاهده پلن اجرایی کوئری
--Show Estimate Execution Plan & Actual Execution Plan
SELECT * FROM MemOptTable
	WHERE ID=123
GO
SELECT * FROM DiskTable
	WHERE ID=123
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Memory Optimized برای جداول NonClustered Index بررسی 
--بررسی جهت وجود جدول
IF OBJECT_ID('MemOptTable')>0
	DROP TABLE MemOptTable
GO
--Memory Optimized Table  ایجاد یک جدول از نوع
CREATE TABLE MemOptTable
(
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL INDEX IX_DateAdded NONCLUSTERED
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
--درج تعدادی رکورد در بانک اطلاعاتی
INSERT INTO MemOptTable(FullName,DateAdded)
	VALUES ('FullName',GETDATE())
GO 5000
--بررسی تعداد رکوردهای درج شده
SELECT COUNT(ID) FROM MemOptTable
GO
SELECT * FROM MemOptTable
GO
--مشاهده پلن اجرایی کوئری
--Show Estimate Execution Plan & Actual Execution Plan
--Bookmark Lookup فاقد
SELECT * FROM MemOptTable
	WHERE DateAdded ='2018-08-21 20:01:35.483'
GO
SELECT * FROM MemOptTable
	WHERE DateAdded >='2018-08-21 20:01:35.483' AND  DateAdded<='2018-08-21 20:01:35.888'
	--DATEADD(SECOND,-100,GETDATE()) AND DateAdded <=GETDATE()
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Memory Optimized Table بررسی وضعیت تخصیص حافظه به جداول 
SELECT 
	OBJECT_NAME(object_id) ObjectName,
    Object_Id,
    SUM( memory_allocated_for_indexes_kb + memory_allocated_for_table_kb) AS MemoryAllocated_Object_In_KB, 
    SUM( memory_used_by_indexes_kb + memory_used_by_table_kb) AS MemoryUsed_Object_In_KB 
FROM sys.dm_db_xtp_table_memory_stats
WHERE object_id>0
GROUP by object_id
GO
--مانیتور کردن مقدار حافظه مصرفی
SELECT t.object_id
    ,t.NAME
    ,ISNULL((
            SELECT CONVERT(DECIMAL(18, 2), (TMS.memory_used_by_table_kb) / 1024.00)
            ), 0.00) AS table_used_memory_in_mb
    ,ISNULL((
            SELECT CONVERT(DECIMAL(18, 2), (TMS.memory_allocated_for_table_kb - TMS.memory_used_by_table_kb) / 1024.00)
            ), 0.00) AS table_unused_memory_in_mb
    ,ISNULL((
            SELECT CONVERT(DECIMAL(18, 2), (TMS.memory_used_by_indexes_kb) / 1024.00)
            ), 0.00) AS index_used_memory_in_mb
    ,ISNULL((
            SELECT CONVERT(DECIMAL(18, 2), (TMS.memory_allocated_for_indexes_kb - TMS.memory_used_by_indexes_kb) / 1024.00)
            ), 0.00) AS index_unused_memory_in_mb
FROM sys.tables t
INNER JOIN sys.dm_db_xtp_table_memory_stats TMS ON (t.object_id = TMS.object_id)
GO

--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Native Compiled Stored Procedureآشنایی با 
GO
IF OBJECT_ID('DiskTable')>0
	DROP TABLE DiskTable
GO
--Disk table (non-Memory Optimized) ایجاد جدول از نوع 
CREATE TABLE DiskTable
(
    ID INT NOT NULL PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
)
GO
-- برای پر کردن جدول SP ایجاد یک 
CREATE PROCEDURE usp_LoadDiskTable (@maxRows INT, @FullName NVARCHAR(200))
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @i INT = 1
    WHILE @i <= @maxRows
    BEGIN
        INSERT INTO DiskTable VALUES(@i, @FullName, GETDATE())
        SET @i = @i+1
    END
END
GO
--------------------------------------------------------------------
--Memory Optimized Table  ایجاد یک جدول از نوع
IF OBJECT_ID('MemOptTable')>0
	DROP TABLE MemOptTable
GO
CREATE TABLE MemOptTable
(
    ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
-- Native Compiled Stored Procedure از نوعSP ایجاد یک
CREATE PROCEDURE usp_LoadMemOptTable (@maxRows INT, @FullName NVARCHAR(200))
WITH
    NATIVE_COMPILATION, 
    SCHEMABINDING, 
    EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE='us_english')
    DECLARE @i INT = 1
    WHILE @i <= @maxRows
    BEGIN
        INSERT INTO dbo.MemOptTable VALUES(@i, @FullName, GETDATE())
        SET @i = @i+1
    END
END
GO
--------------------------------------------------------------------
--در حالت های مختلف Disk Table تست
GO
SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO
--Disk Table (without SP) درج دیتا در جدول از نوع 
SET NOCOUNT ON
DECLARE @StartTime DATETIME = GETDATE()
DECLARE @TotalTime INT
DECLARE @i INT = 1
DECLARE @MaxRows INT = 10000
DECLARE @FullName VARCHAR(200)= REPLICATE('A',200)

WHILE @i <= @MaxRows
BEGIN
    INSERT INTO DiskTable VALUES(@i, @FullName, GETDATE())
    SET @i = @i+1
END
SET @TotalTime = DATEDIFF(ms,@StartTime,GETDATE())
SELECT 'Disk Table Load: ' + CAST(@TotalTime AS VARCHAR) + ' ms (without SP)'
GO
--بررسی تعداد رکوردهای درج شده
SP_SPACEUSED 'DiskTable'
/*
Disk Table Load (without SP) :8473 ms
*/
GO

--Disk Table (with simple SP) درج دیتا در جدول از نوع 
TRUNCATE TABLE DiskTable
GO
DECLARE @StartTime DATETIME = GETDATE()
DECLARE @MaxRows INT = 10000
DECLARE @FullName VARCHAR(200)= REPLICATE('A',200)
DECLARE @TotalTime INT
EXEC usp_LoadDiskTable @maxRows, @FullName
SET @TotalTime = DATEDIFF(ms,@StartTime,GETDATE())
SELECT 'Disk Table Load: ' + CAST(@TotalTime AS VARCHAR) + ' ms (with simple SP)'
GO
--بررسی تعداد رکوردهای درج شده
SP_SPACEUSED 'DiskTable'
/*
Disk Table Load (with SP) :4040 ms
*/
--------------------------------------------------------------------
--در حالت های مختلف Memory-Optimized Table تست
GO
--Memory Optimized Table (without SP) درج دیتا در جدول از نوع 
SET NOCOUNT ON
DECLARE @StartTime DATETIME = GETDATE()
DECLARE @TotalTime INT
DECLARE @i INT = 1
DECLARE @MaxRows INT = 10000
DECLARE @FullName VARCHAR(200)= REPLICATE('A',200)
 
WHILE @i <= @maxRows
BEGIN
    INSERT INTO MemOptTable VALUES(@i, @FullName, GETDATE())
    SET @i = @i+1
END
SET @TotalTime = DATEDIFF(ms,@StartTime,GETDATE())
SELECT 'Memory Optimized Table  Load: ' + CAST(@TotalTime AS VARCHAR) + ' ms (without SP)'
GO
--بررسی تعداد رکوردهای درج شده
SELECT COUNT(*) FROM MemOptTable
GO 
/*
Memory Optimized Table Load (without SP) :3990 ms
*/
GO 
--Memory Optimized Table (with Native Compiled SP) درج دیتا در جدول از نوع 
DELETE FROM MemOptTable
TRUNCATE TABLE MemOptTable

GO
DECLARE @StartTime DATETIME = GETDATE()
DECLARE @MaxRows INT = 10000
DECLARE @FullName VARCHAR(200)= REPLICATE('A',200)
DECLARE @TotalTime INT
EXEC usp_LoadMemOptTable @maxRows, @FullName
SET @TotalTime = DATEDIFF(ms,@StartTime,GETDATE())
SELECT 'Memory Optimized Table Load: ' + CAST(@TotalTime AS VARCHAR) + ' ms (with Native Compiled SP)'
GO
--بررسی تعداد رکوردهای درج شده
SELECT COUNT(*) FROM MemOptTable
GO 
/*
Memory Optimized Table  Load (without SP) :450 ms
*/
--------------------------------------------------------------------
/*
Disk Table Load (without SP) : 8473 ms
Disk Table Load (with SP) : 4040 ms
Memory Optimized Table  Load (without SP) : 3990 ms
Memory Optimized Table  (without SP) : 450 ms
*/
--بررسی کد کامپایل شده
SELECT OBJECT_ID('DBO.usp_LoadMemOptTable')
GO
SELECT name, description FROM sys.dm_os_loaded_modules
	WHERE name like '%xtp_p_%'

--------------------------------------------------------------------
--مربوط به آن حذف می شودDLL اتوماتیک SP هنگام حذف 
--ها نمی باشدDLL لزومی به تهیه نسخه پشتیبان از
GO
--------------------------------------------------------------------
--Natively Compiled Function ایجاد 
USE SQL2017_Demo
GO
CREATE FUNCTION dbo.DateOnlyHekaton (@Input DATETIME)
RETURNS DATETIME
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')
  RETURN DATEADD(dd,DATEDIFF(dd,0,@Input),0);
END
GO
--اصلاح فانکشن 
ALTER FUNCTION dbo.DateOnlyHekaton (@Input DATETIME)
RETURNS DATETIME
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')
  RETURN DATEADD(dd,DATEDIFF(dd,0,@Input),0);
END
GO
--------------------------------------------------------------------
--Natively After Triggerایجاد 
USE SQL2017_Demo
GO
IF OBJECT_ID('MemOptTable2')>0
	DROP TABLE MemOptTable2
GO
CREATE TABLE MemOptTable2
(
    ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) COLLATE PERSIAN_100_CI_AI NOT NULL, 
    DateAdded DATETIME  NULL,
	Comments NVARCHAR(MAX),
	Picture VARBINARY(MAX),
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
IF OBJECT_ID('MemOptTable3')>0
	DROP TABLE MemOptTable3
GO
CREATE TABLE MemOptTable3
(
    ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) COLLATE PERSIAN_100_CI_AI NOT NULL, 
    DateAdded DATETIME  NULL,
	Comments NVARCHAR(MAX),
	Picture VARBINARY(MAX),
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
CREATE OR ALTER TRIGGER  TriggerTest ON MemOptTable2  
WITH NATIVE_COMPILATION, SCHEMABINDING
	FOR DELETE
AS BEGIN ATOMIC WITH
(
	TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english'
)
	INSERT INTO dbo.MemOptTable3 (ID,FullName,DateAdded,Comments,Picture)
	SELECT 
		ID,FullName,DateAdded,Comments,Picture
	FROM Deleted 
END
GO
INSERT INTO MemOptTable2 (ID,FullName,DateAdded,Comments,Picture) VALUES 
	(3,N'مسعود طاهری',GETDATE(),'Comments1',NULL),
	(4,N'فرید طاهری',GETDATE(),'Comments2',NULL)
GO
SELECT * FROM  MemOptTable2
SELECT * FROM  MemOptTable3
GO
DELETE FROM MemOptTable2 WHERE ID=4
GO
