
--کش کردن جداول موقت به منظور عملکر بهینه
--1 IMA + 1 Data Page  نگهداری
--ساخت مجدد جدول منجر به استفاده از این صفحات خواهد شد
GO
--------------------------------------------------------------------
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
--------------------------------------------------------------------
USE Temp_Test
GO
-- Create a new stored procedure
CREATE PROCEDURE PopulateTempTable
AS
BEGIN
	-- Create a new temp table
	CREATE TABLE #TempTable
	(
		Col1 INT IDENTITY(1, 1),
		Col2 CHAR(4000),
		Col3 CHAR(4000)
	)
 
	-- Create a unique clustered index on the previous created temp table
	CREATE UNIQUE CLUSTERED INDEX idx_c1 ON #TempTable(Col1)
 
	-- Insert 10 dummy records
	DECLARE @i INT = 0
	WHILE (@i < 10)
	BEGIN
		INSERT INTO #TempTable VALUES ('Masoud', 'Taheri')
		SET @i += 1
	END
END
GO

DECLARE @table_counter_before_test BIGINT;
SELECT @table_counter_before_test = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'
 
DECLARE @i INT = 0
WHILE (@i < 1000)
BEGIN
	EXEC PopulateTempTable
	SET @i += 1
END
 
DECLARE @table_counter_after_test BIGINT;
SELECT @table_counter_after_test = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'
 
PRINT 'Temp tables created during the test: ' + CONVERT(VARCHAR(100), @table_counter_after_test - @table_counter_before_test)
GO

--------------------------------------------------------------------
--کاری انجام دهیم که کش شود
ALTER PROCEDURE PopulateTempTable
AS
BEGIN
	-- Create a new temp table
	CREATE TABLE #TempTable
	(
		Col1 INT IDENTITY(1, 1) PRIMARY KEY, -- This creates also a Unique Clustered Index
		Col2 CHAR(4000),
		Col3 CHAR(4000)
	)
 
	-- Insert 10 dummy records
	DECLARE @i INT = 0
	WHILE (@i < 10)
	BEGIN
		INSERT INTO #TempTable VALUES ('Klaus', 'Aschenbrenner')
		SET @i += 1
	END
END
GO


DECLARE @table_counter_before_test BIGINT;
SELECT @table_counter_before_test = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'
 
DECLARE @i INT = 0
WHILE (@i < 1000)
BEGIN
	EXEC PopulateTempTable
	SET @i += 1
END
 
DECLARE @table_counter_after_test BIGINT;
SELECT @table_counter_after_test = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'
 
PRINT 'Temp tables created during the test: ' + CONVERT(VARCHAR(100), @table_counter_after_test - @table_counter_before_test)
GO


--Non Clustered Index
ALTER PROCEDURE PopulateTempTable
AS
BEGIN
	-- Create a new temp table
	CREATE TABLE #TempTable
	(
		Col1 INT IDENTITY(1, 1) PRIMARY KEY, -- This creates also a Unique Clustered Index
		Col2 CHAR(100) INDEX idx_Col2,
		Col3 CHAR(100) INDEX idx_Col3
	)
 
	-- Insert 10 dummy records
	DECLARE @i INT = 0
	WHILE (@i < 10)
	BEGIN
		INSERT INTO #TempTable VALUES ('Klaus', 'Aschenbrenner')
		SET @i += 1
	END
END
GO