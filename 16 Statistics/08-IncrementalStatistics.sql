
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('SQL2017_Demo')>0
BEGIN
	ALTER DATABASE SQL2017_Demo SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE SQL2017_Demo
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE SQL2017_Demo
 ON  PRIMARY
( 
    NAME = N'SQL2017_Demo', 
    FILENAME = N'C:\Dump\SQL2017_Demo.mdf', 
    SIZE = 5120KB, 
    FILEGROWTH = 1024KB 
 )
 LOG ON 
 ( 
    NAME = N'SQL2017_Demo_log', 
    FILENAME = N'C:\Dump\SQL2017_Demo_log.ldf', 
    SIZE = 1024KB, 
    FILEGROWTH = 10%
 )
GO
--------------------------------------------------------------------
USE SQL2017_Demo
GO
--ایجاد پارتیشن فانکشن
CREATE PARTITION FUNCTION TransactionRangePF1 (DATETIME)
AS RANGE RIGHT FOR VALUES 
(
   '20130101', '20130301', '20130601', '20130901',  
   '20140101', '20140301', '20140601', '20140901',  
   '20150101', '20150301', '20150601', '20150901'
);
GO
--SCHEME ایجاد پارتیشن 
CREATE PARTITION SCHEME TransactionsPS1 AS PARTITION TransactionRangePF1 ALL TO ([PRIMARY]);
GO 
--ایجاد یک جدول به صورت پارتیشن شده
CREATE TABLE dbo.TransactionHistory 
(
  TransactionID        INT      NOT NULL, 
  ProductID            INT      NOT NULL,
  ReferenceOrderID     INT      NOT NULL,
  ReferenceOrderLineID INT      NOT NULL DEFAULT (0),
  TransactionDate      DATETIME NOT NULL DEFAULT (GETDATE()),
  TransactionType      NCHAR(1) NOT NULL,
  Quantity             INT      NOT NULL,
  ActualCost           MONEY    NOT NULL,
  ModifiedDate         DATETIME NOT NULL DEFAULT (GETDATE()),
  CONSTRAINT CK_TransactionType 
    CHECK (UPPER(TransactionType) IN (N'W', N'S', N'P'))
) 
GO
--ايجاد يك ايندكس پارتيشن بندي شده جديد
DROP INDEX IX_Cluster ON TransactionHistory

--ايجاد يك ايندكس پارتيشن بندي شده جديد
CREATE UNIQUE CLUSTERED INDEX IX_Cluster ON
	 TransactionHistory(TransactionDate,TransactionID)
	-- WITH (STATISTICS_INCREMENTAL = ON)
	 ON TransactionsPS1(TransactionDate)
	

GO
--درج تعدادی رکورد به صورت تستی در جدول
INSERT INTO dbo.TransactionHistory
	SELECT * FROM AdventureWorks2017.Production.TransactionHistory
GO
--به ازای یک ایندکس خاصIncremental Statistics فعال سازی قابلیت 
ALTER INDEX IX_Cluster ON TransactionHistory REBUILD
	WITH (STATISTICS_INCREMENTAL = ON)
GO
--بررسی حجم جدول
SP_SPACEUSED TransactionHistory
GO
--مشاهده پارتیشن های مربوط به جدول
SELECT * FROM sys.partitions
  WHERE object_id = OBJECT_ID('dbo.TransactionHistory');
GO
--------------------------------------------------------------------
--و Statistics ساخت
--Incremental Statistics فعال سازی قابلیت 
CREATE STATISTICS TransactionDate1 ON dbo.TransactionHistory(TransactionDate) 
	WITH FULLSCAN, INCREMENTAL = ON;
GO
--Incremental Statistics مشاهده لیست 
SELECT * FROM SYS.STATS WHERE is_incremental = 1
GO
--Statistics مشاهده وضعیت داده های موجود در 
SELECT 
	*
FROM sys.dm_db_stats_properties_internal(OBJECT_ID('TransactionHistory'),2)
ORDER BY node_id;

--Statistics ساخت
CREATE STATISTICS TransactionDate2 ON dbo.TransactionHistory(TransactionDate) 
	WITH FULLSCAN
GO

SELECT * FROM SYS.STATS WHERE name ='TransactionDate2'
GO
--Statistics مشاهده وضعیت داده های موجود در 
SELECT 
	*
FROM sys.dm_db_stats_properties_internal(OBJECT_ID('TransactionHistory'),3)
ORDER BY node_id;

--Statistics مشاهده 
DBCC SHOW_STATISTICS (TransactionHistory,TransactionDate1) WITH HISTOGRAM
GO
--Statistics مشاهده 
DBCC SHOW_STATISTICS (TransactionHistory,TransactionDate2) WITH HISTOGRAM
GO
--درج دیتا تستی در جدول پارتیشن شده
INSERT INTO dbo.TransactionHistory
SELECT 
	TransactionID + 9999 
    ,ProductID
    ,ReferenceOrderID
    ,ReferenceOrderLineID
    ,TransactionDate
    ,TransactionType
    ,Quantity
    ,ActualCost
    ,ModifiedDate
FROM AdventureWorks2017.Production.TransactionHistory
WHERE TransactionDate BETWEEN '20140101' AND '20140131'
GO
--های یک پارتیشن خاصStatistics به روز رسانی
UPDATE STATISTICS dbo.TransactionHistory(TransactionDate1) 
  WITH RESAMPLE ON PARTITIONS(1,2);
GO
--های یک پارتیشن خاصStatistics به روز رسانی
UPDATE STATISTICS dbo.TransactionHistory(TransactionDate2) 
  WITH RESAMPLE ON PARTITIONS(1,2);
GO
/*
Statistics کمتر برای فرآیندهای نگهداری IO 
تخمین دقیق تر
*/
--------------------------------------------------------------------
--ایجاد جدولی مشابه جدول قبل 
--Incremental Statistics بدون در نظر گرفتن 
CREATE TABLE dbo.TransactionHistory2
(
  TransactionID        INT      NOT NULL, 
  ProductID            INT      NOT NULL,
  ReferenceOrderID     INT      NOT NULL,
  ReferenceOrderLineID INT      NOT NULL DEFAULT (0),
  TransactionDate      DATETIME NOT NULL DEFAULT (GETDATE()),
  TransactionType      NCHAR(1) NOT NULL,
  Quantity             INT      NOT NULL,
  ActualCost           MONEY    NOT NULL,
  ModifiedDate         DATETIME NOT NULL DEFAULT (GETDATE()),
  CONSTRAINT CK_TransactionType2 
    CHECK (UPPER(TransactionType) IN (N'W', N'S', N'P'))
) 
GO
CREATE UNIQUE CLUSTERED INDEX IX_Cluster ON
	 TransactionHistory2(TransactionDate,TransactionID)ON TransactionsPS1(TransactionDate)
GO
INSERT INTO dbo.TransactionHistory2
	SELECT * FROM AdventureWorks2017.Production.TransactionHistory
GO
INSERT INTO dbo.TransactionHistory2
SELECT 
	TransactionID + 9999 
    ,ProductID
    ,ReferenceOrderID
    ,ReferenceOrderLineID
    ,TransactionDate
    ,TransactionType
    ,Quantity
    ,ActualCost
    ,ModifiedDate
FROM AdventureWorks2017.Production.TransactionHistory
WHERE TransactionDate BETWEEN '20140101' AND '20140131'
GO
--مقایسه تخمین تعداد رکوردها
SELECT * FROM TransactionHistory
WHERE TransactionDate BETWEEN '20140101' AND '20140131'
GO
SELECT * FROM TransactionHistory2
WHERE TransactionDate BETWEEN '20140101' AND '20140131'
GO
--------------------------------------------------------------------
--به ازای بانک اطلاعاتیAuto Incremental Statistics فعال سازی قابلیت 
ALTER DATABASE SQL2017_Demo SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = ON)
GO
--Incremental Statistics مشاهده لیست 
SELECT * FROM SYS.STATS WHERE is_incremental = 1
GO
SELECT * FROM TransactionHistory
	WHERE ProductID=784
GO
--Incremental Statistics مشاهده لیست 
SELECT * FROM SYS.STATS WHERE is_incremental = 1
GO
SELECT 
	*
FROM sys.dm_db_stats_properties_internal(OBJECT_ID('TransactionHistory'),4)
ORDER BY node_id;
