
-- Table Variable و Cardinality Estimation

--تخمین تعداد رکوردها برای متغییرهای جدولی همیشه 1 است


SET STATISTICS TIME ON
SET STATISTICS IO ON

USE AdventureWorks2017
GO
Declare @TV_SalesOrderDetail Table
(
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[LineTotal]  [money],
	[rowguid] [uniqueidentifier] ROWGUIDCOL,
	[ModifiedDate] [datetime] NOT NULL
)

INSERT INTO @TV_SalesOrderDetail
SELECT [SalesOrderID]
      ,[SalesOrderDetailID]
      ,[CarrierTrackingNumber]
      ,[OrderQty]
      ,[ProductID]
      ,[SpecialOfferID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[LineTotal]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Sales].[SalesOrderDetail]

--این کوئری توجه کنید به قسمت متغییر جدولی Actual Plan به
--Estimated Number Of Rows
SELECT 
	SOD.UnitPrice,
	SOH.DueDate, SOH.OrderDate
FROM @TV_SalesOrderDetail SOD
INNER JOIN [Sales].[SalesOrderHeader] SOH ON sod.SalesOrderID=SOH.SalesOrderID
WHERE 
	SOH.OrderDate BETWEEN '2011-07-01' AND '2011-07-31'

--راه حل اول رفع مشکل
--را دقت کنید Join تفاوت اپراتور مربوط به 
SELECT 
	SOD.UnitPrice,
	SOH.DueDate, SOH.OrderDate
FROM @TV_SalesOrderDetail SOD
INNER JOIN [Sales].[SalesOrderHeader] SOH ON sod.SalesOrderID=SOH.SalesOrderID
WHERE 
	SOH.OrderDate BETWEEN '2011-07-01' AND '2011-07-31'OPTION(RECOMPILE)

GO
--------------------------------------------------------------------
--راه حل دوم رفع مشکل
/* 
Trace Flag 2453 = OPTION(RECOMPILE)
This TF was introduced in  SQL Server 2012 SP2 and SQL Server 2014 CU3
فعال کنیم Instance حواستان باشد هیچ لزومی ندارد آن را به ازای کل 
*/

USE AdventureWorks2017
GO

DBCC TRACEON(2453)
DECLARE @TV_SalesOrderDetail TABLE
(
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[LineTotal]  [money],
	[rowguid] [uniqueidentifier] ROWGUIDCOL,
	[ModifiedDate] [datetime] NOT NULL
)

INSERT INTO @TV_SalesOrderDetail
SELECT [SalesOrderID]
      ,[SalesOrderDetailID]
      ,[CarrierTrackingNumber]
      ,[OrderQty]
      ,[ProductID]
      ,[SpecialOfferID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[LineTotal]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Sales].[SalesOrderDetail]

Select SOD.UnitPrice,
SOH.DueDate, SOH.OrderDate
from @TV_SalesOrderDetail SOD
join [Sales].[SalesOrderHeader] SOH
on sod.SalesOrderID=SOH.SalesOrderID
Where SOH.OrderDate between '2011-07-01' AND '2011-07-31'
GO
DBCC TRACEOFF(2453)
GO
--------------------------------------------------------------------
/*
تخصص حافظه و داستان های مربوط به آن
Statistics and Query Memory Grants
*/
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('NikAmoozDB2017')>0
BEGIN
	ALTER DATABASE NikAmoozDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE NikAmoozDB2017
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE NikAmoozDB2017
GO
USE NikAmoozDB2017
GO
--بررسی جهت وجود جدول و حذف آن
DROP TABLE IF EXISTS MemoryGrantDemo
GO
CREATE TABLE dbo.MemoryGrantDemo
(
	ID int not null,
	Col int not null,
	Placeholder char(8000)
)
GO
--ایجاد ایندکس
CREATE UNIQUE CLUSTERED INDEX IDX_MemoryGrantDemo_ID ON dbo.MemoryGrantDemo(ID)
GO
--درج تعدادی رکورد در جدول
--65536 rows
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT INTO dbo.MemoryGrantDemo(ID,Col,Placeholder)
	SELECT ID, ID % 100, CONVERT(CHAR(100),ID)
	FROM IDs;
GO
--NonClustered Index ایجاد 
CREATE NONCLUSTERED INDEX IDX_MemoryGrantDemo_Col  ON dbo.MemoryGrantDemo(Col);
GO

/*
درج تعدادی رکورد در جدول
656 rows
درج این تعداد رکورد باعث می شود که شرایط به روز رسانی 
فراهم نشود Statistics 
*/
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 rows
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N2 AS T2) -- 1,024 ROWS
,IDs(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT INTO dbo.MemoryGrantDemo(ID,Col,Placeholder)
	SELECT 100000 + ID, 1000, CONVERT(CHAR(100),ID)
	FROM IDs
	WHERE ID <= 656;
GO
-- Enable "Include Actual Execution Plan"
-- Check estimated # of rows vs. actual, Memory Grant size and Sort Warnings
DECLARE @Dummy INT
SET STATISTICS TIME ON
SELECT @Dummy = ID FROM dbo.MemoryGrantDemo WHERE Col = 1 ORDER BY Placeholder
SELECT @Dummy = ID FROM dbo.MemoryGrantDemo WHERE Col = 1000 ORDER BY Placeholder
SET STATISTICS TIME OFF
GO
--هاStats بررسی وضعیت تغییرات
--های به روز نشدهStatistics نمایش 
SELECT DISTINCT
	OBJECT_NAME(SI.object_id) as Table_Name
	,SI.[name] AS Statistics_Name
	,STATS_DATE(SI.object_id, SI.index_id) AS Last_Stat_Update_Date
	,SSI.rowmodctr AS RowModCTR
	,SP.rows AS Total_Rows_In_Table
	,'UPDATE STATISTICS ['+SCHEMA_NAME(SO.schema_id)+'].[' 
	+ object_name(SI.object_id) + ']' 
	+ SPACE(2) + SI.[name] AS Update_Stats_Script
FROM 
    sys.indexes AS SI (nolock) 
JOIN sys.objects AS SO (nolock) 
	ON SI.object_id=SO.object_id
JOIN sys.sysindexes SSI (nolock)
	ON SI.object_id=SSI.id
		AND SI.index_id=SSI.indid 
JOIN sys.partitions AS SP
	ON SI.object_id=SP.object_id
WHERE SSI.rowmodctr>0
	AND STATS_DATE(SI.object_id, SI.index_id) IS NOT NULL
	AND SO.type='U'
ORDER BY SSI.rowmodctr DESC
GO
/*
--فورس کردن برای به روز رسانی
اجرای مجدد کوئری ها
*/
UPDATE STATISTICS [dbo].[MemoryGrantDemo]  IDX_MemoryGrantDemo_Col
GO

