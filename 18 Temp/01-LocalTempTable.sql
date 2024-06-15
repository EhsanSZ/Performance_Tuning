
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
--بررسی جهت وجود جدول و ساخت مجدد آن
DROP TABLE IF EXISTS #LocalTempTable
GO
--ایجاد جداول موقت محلی 
CREATE TABLE #LocalTempTable
(
	EmployeeID INT,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
/*Object Exlorer*/
--Temp_Test نمایش جدول در بانک اطلاعاتی 
--Tempdb نمایش جدول در بانک اطلاعات
GO
SELECT * FROM #LocalTempTable
GO
INSERT INTO #LocalTempTable(EmployeeID,FirstName,LastName) 
	VALUES (1,N'مسعود',N'طاهری')
GO
SELECT * FROM #LocalTempTable
GO
/*
دیگر Session اجرای کوئری در یک 
New Session
**
قطع اتصال و اتصال مجدد جهت بررسی وضعیت
*/
SELECT * FROM #LocalTempTable
GO
--------------------------------------------------------------------
--Drop Temp Table If Exists
USE AdventureWorks2017
GO
--بررسی شود TempDb جدول موقت در یک بانک ایجاد شده و وجود آن در 
IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
    DROP TABLE #Temp
GO
SELECT 
	H.SalesOrderID, 
	H.SalesPersonID,
	H.CustomerID,
	H.OrderDate
	INTO #Temp
FROM AdventureWorks2017.Sales.SalesOrderHeader H
GO
SELECT * FROM  #Temp
GO
--بررسی سریال تخصیص یافته به جدول 
SELECT OBJECT_ID(N'tempdb..#Temp')
SELECT OBJECT_ID(N'tempdb.dbo.#Temp')
GO
--------------------------------------------------------------------
--Disconnect & Connect
--کلیه این دستورات با هم ایجاد شوند
USE Temp_Test
GO
SELECT 'Before Create Temp Table'
GO
SELECT @@SPID AS Current_SessionID
GO
--TempDb جاری در Session صفحات استفاده شده
SELECT 
	user_objects_alloc_page_count,
	user_objects_dealloc_page_count 
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO
--ایجاد یک جدول موقت
CREATE TABLE #TempTable (Col1 INT)
--درج تعدادی رکورد تستی در جدول
INSERT INTO #TempTable (Col1)
SELECT TOP 3000 ROW_NUMBER() OVER(ORDER BY a.name)
	FROM sys.all_objects a CROSS JOIN sys.all_objects b
GO
SELECT 'After Create Temp Table'
GO
--TempDb جاری در Session صفحات استفاده شده
SELECT 
	user_objects_alloc_page_count,
	user_objects_dealloc_page_count 
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO
-- Clean up
DROP TABLE #TempTable
GO
SELECT 'After Delete Temp Table'
GO
--TempDb جاری در Session صفحات استفاده شده
SELECT 
	user_objects_alloc_page_count,
	user_objects_dealloc_page_count 
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO