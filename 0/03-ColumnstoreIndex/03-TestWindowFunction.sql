
/*
Columnstore Index ها با استفاده از Window Function تست
http://tsql.solidq.com/SourceCodes/This%20batch-mode%20Window%20Aggregate%20operator%20will%20change%20your%20life!.txt
*/
USE master
GO
IF DB_ID('TestWindowFunctionDB')>0
BEGIN
	ALTER DATABASE TestWindowFunctionDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE TestWindowFunctionDB
END
GO
--ساخت بانک اطلاعاتی
CREATE DATABASE TestWindowFunctionDB
ON PRIMARY 
	(NAME = N'TestWindowFunctionDB', FILENAME = N'E:\Database\TestWindowFunctionDB.mdf')
LOG ON 
	(NAME = N'TestWindowFunctionDB_log', FILENAME = N'E:\Database\TestWindowFunctionDB_log.ldf')
GO
USE TestWindowFunctionDB
GO
--------------------------------------------------------------------
/*
ایجاد جداول و پر کردن آنها
*/
USE TestWindowFunctionDB
GO
SET NOCOUNT ON;
GO
DROP FUNCTION IF EXISTS dbo.GetNums;
GO
--ساخت فانکشن
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
             FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO
--و پر کردن آنRow Based ایجاد یک جدول 
DROP TABLE IF EXISTS dbo.Transactions;
GO
CREATE TABLE dbo.Transactions
(
  actid  INT   NOT NULL,
  tranid INT   NOT NULL,
  val    MONEY NOT NULL,
  CONSTRAINT PK_Transactions PRIMARY KEY(actid, tranid)
);
GO
--Row Based پر کردن جدول 
DECLARE
  @num_partitions     AS INT = 200,
  @rows_per_partition AS INT = 50000;

INSERT INTO dbo.Transactions WITH (TABLOCK) (actid, tranid, val)
  SELECT NP.n, RPP.n,
    (ABS(CHECKSUM(NEWID())%2)*2-1) * (1 + ABS(CHECKSUM(NEWID())%5))
  FROM dbo.GetNums(1, @num_partitions) AS NP
    CROSS JOIN dbo.GetNums(1, @rows_per_partition) AS RPP;
GO
--مشاهده تعداد رکوردها و حجم
SP_SPACEUSED Transactions
GO       
--بررسی نمونه ای از رکوردها
SELECT TOP 10 * FROM Transactions
GO
--Clustered Columnstore Index ایجاد یک جدول به صورت 
DROP TABLE IF EXISTS dbo.TransactionsCS;
SELECT * INTO dbo.TransactionsCS FROM dbo.Transactions;
CREATE CLUSTERED COLUMNSTORE INDEX idx_cs ON dbo.TransactionsCS;
GO
--مشاهده تعداد رکوردها و حجم
SP_SPACEUSED TransactionsCS
GO
/*
--و پر کردن آنRow Based ایجاد یک جدول 
جعلی Non Clustered Columnstore به همراه یک 
-- TransactionsDCS
-- Traditional rowstore B-tree index
--   + dummy empty filtered nonclustered columnstore index to enable using batch mode operators
*/
DROP TABLE IF EXISTS dbo.TransactionsDCS;
SELECT * INTO dbo.TransactionsDCS FROM dbo.Transactions;
ALTER TABLE dbo.TransactionsDCS
  ADD CONSTRAINT PK_TransactionsDCS PRIMARY KEY(actid, tranid);
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_cs_dummy ON dbo.TransactionsDCS(actid)
  WHERE actid = -1 AND actid = -2;
GO
--مشاهده تعداد رکوردها و حجم
SP_SPACEUSED TransactionsDCS
GO
--------------------------------------------------------------------
/*
--Window Aggregate اجرای کوئری های 
--Actual Execution Plan نمایش 
Frameless aggregate window functions
*/
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
GO
USE TestWindowFunctionDB
GO
-- Query 1, row mode over rowstore
-- Plan in Figure 2, parallel, Table Spool, no sort, row mode
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid) AS acttotal
FROM dbo.Transactions
WHERE TRANID BETWEEN 885 AND 2000

GO
-- If data wasn't ordered in an index, would require a sort (row mode)
-- Query 2, batch mode over columnstore
-- Plan in Figure 3, parallel, no spool, sort, most operators use batch mode
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid) AS acttotal
FROM dbo.TransactionsCS
WHERE TRANID BETWEEN 885 AND 2000
GO
-- Query 3, batch mode over rowstore (by having a dummy columnstore index)
-- Plan in Figure 4, serial, no spool, no sort, Index Scan uses row mode, all other operators use batch mode
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid) AS acttotal
FROM dbo.TransactionsDCS
WHERE TRANID BETWEEN 885 AND 2000
GO
--------------------------------------------------------------------
/*
--Window Aggregate اجرای کوئری های 
--Actual Execution Plan نمایش 
-- Ranking window functions
*/
SET STATISTICS IO ON 
GO
USE TestWindowFunctionDB
GO
-- Row mode, when index exists already very optimized
-- Query 1, row mode over rowstore, no sort
-- Plan in Figure 1, serial, no spool, no sort, row mode
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY tranid) AS rownum,
  RANK() OVER(PARTITION BY actid ORDER BY tranid) AS rnk,
  DENSE_RANK() OVER(PARTITION BY actid ORDER BY tranid) AS drnk
FROM dbo.Transactions
WHERE TRANID BETWEEN 885 AND 2000
GO
-- Row mode, when index does not exist, slow because of sort
-- Query 2, row mode over rowstore, with sort
-- Plan in Figure 2, scan and sort parallel, window functions calculation serial, no spool, sort, row mode
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val) AS rownum,
  RANK() OVER(PARTITION BY actid ORDER BY val) AS rnk,
  DENSE_RANK() OVER(PARTITION BY actid ORDER BY val) AS drnk
FROM dbo.Transactions
WHERE TRANID BETWEEN 885 AND 2000
GO
-- In batch mode, needs sort, but much faster
-- Query 3, batch mode over columnstore
-- Plan in Figure 3, parallel, no spool, sort, batch mode
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY tranid) AS rownum,
  RANK() OVER(PARTITION BY actid ORDER BY tranid) AS rnk,
  DENSE_RANK() OVER(PARTITION BY actid ORDER BY tranid) AS drnk
FROM dbo.TransactionsCS
WHERE TRANID BETWEEN 885 AND 2000
GO
-- NTILE is slow in row mode due to use of disk spool
-- Query 7, row mode over rowstore
-- Plan in Figure 6, serial, Table Spool, no sort, row mode
SELECT actid, tranid, val,
  NTILE(10) OVER(PARTITION BY actid ORDER BY tranid) AS ntile10
FROM dbo.Transactions
WHERE TRANID BETWEEN 885 AND 2000
GO
-- Fast in batch mode even when sort is needed
-- Query 8, batch mode over columnstore
-- Plan in Figure 7, count parallel / segment + sequence project serial, no spool, sort, count batch mode / segment + sequence project row mode
SELECT actid, tranid, val,
  NTILE(10) OVER(PARTITION BY actid ORDER BY tranid) AS ntile10
FROM dbo.TransactionsCS
WHERE TRANID BETWEEN 885 AND 2000
GO
-- Faster in batch mode over rowstore when no need for sort
-- Query 9, batch mode over rowstore, no sort
-- Plan in Figure 8, serial, no spool, no sort, index scan row mode, rest batch mode
SELECT actid, tranid, val,
  NTILE(10) OVER(PARTITION BY actid ORDER BY tranid) AS ntile10
FROM dbo.TransactionsDCS
WHERE TRANID BETWEEN 885 AND 2000
GO
--------------------------------------------------------------------
/*
--Window Aggregate اجرای کوئری های 
--Actual Execution Plan نمایش 
Aggregate window functions with a frame
*/
SET STATISTICS IO ON 
GO
USE TestWindowFunctionDB
GO
-- Without window function
SELECT T1.actid, T1.tranid, T1.val, SUM(T2.val) AS balance
FROM dbo.Transactions AS T1
  INNER JOIN dbo.Transactions AS T2
    ON T2.actid = T1.actid
       AND T2.tranid <= T1.tranid
WHERE T1.TRANID BETWEEN 885 AND 2000
GROUP BY T1.actid, T1.tranid, T1.val;
GO
-- Query 1: row mode over rowstore
-- Plan in Figure 1, serial, fast-track, Window Spool (in-memory), no sort, row mode
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid ORDER BY tranid
                ROWS UNBOUNDED PRECEDING) AS balance
FROM dbo.Transactions
WHERE TRANID BETWEEN 885 AND 2000
GO
-- Query 2: batch mode over columnstore
-- Plan in Figure 2, parallel, no spool, sort, most operators use batch mode
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid ORDER BY tranid
                ROWS UNBOUNDED PRECEDING) AS balance
FROM dbo.TransactionsCS
WHERE TRANID BETWEEN 885 AND 2000
GO
-- Query 3: batch mode over rowstore
-- Plan in Figure 3, serial, no spool, no sort
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid ORDER BY tranid
                ROWS UNBOUNDED PRECEDING) AS balance
FROM dbo.TransactionsDCS
WHERE TRANID BETWEEN 885 AND 2000
GO
--------------------------------------------------------------------
/*
SQL Server 2016
بررسی تغییرات اشاره شده از نسخه 2017 به بعد
*/
Use AdventureworksDW2016CTP3
GO
SP_SPACEUSED 'FactResellerSalesXL_CCI' --513 MB
GO
SP_SPACEUSED 'FactResellerSalesXL_PageCompressed'--681 MB
GO
--Show Actual Execution Plan
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
SELECT COUNT(*) AS CCITableCount
	FROM FactResellerSalesXL_CCI
GO
SELECT COUNT(*) AS PageCompressedTableCount
	FROM FactResellerSalesXL_PageCompressed
GO
--Row Group بررسی تعداد 
SELECT *
FROM sys.dm_db_column_store_row_group_physical_stats
WHERE object_id = object_id('FactResellerSalesXL_CCI')
GO
 --Segment Elimination Diagnostics /*تشخیص حذف برخی از سگمنت ها هنگام بررسی */
SET STATISTICS IO ON
GO
SELECT OrderDateKey FROM FactResellerSalesXL_CCI
	WHERE OrderDateKey > 20141201
GO
SET STATISTICS IO OFF
GO
--Batch  Mode improvements  (Sort Operator)
--Show Actual Execution Plan
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 130
GO
SELECT ProductKey
	,count(ProductKey)
FROM FactResellerSalesXL_CCI
GROUP BY ProductKey
ORDER BY ProductKey
GO
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 120
GO
SELECT ProductKey
	,count(ProductKey)
FROM FactResellerSalesXL_CCI
GROUP BY ProductKey
ORDER BY ProductKey
GO
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 130
GO
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO
--Batch Mode for serial plan
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 130
SELECT ProductKey,sum(TotalProductCost)
FROM FactResellerSalesXL_CCI
GROUP BY ProductKey
OPTION (MAXDOP 1)
GO
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 120
GO
--اجرا کمی کند می باشد
SELECT ProductKey,sum(TotalProductCost)
FROM FactResellerSalesXL_CCI
GROUP BY ProductKey
OPTION (MAXDOP 1)
GO
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 130
GO
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
--Batch mode for Windows aggregates
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 130

SELECT ProductKey,OrderDateKey
	,LEAD(OrderQuantity, 1, 0) OVER (ORDER BY OrderDateKey) AS NextQuota
FROM FactResellerSalesXL_CCI
WHERE orderdatekey IN (	20060301,20060601)
GO
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 120
GO
SELECT ProductKey	,OrderDateKey
	,LEAD(OrderQuantity, 1, 0) OVER (ORDER BY OrderDateKey) AS NextQuota
FROM FactResellerSalesXL_CCI
WHERE orderdatekey IN (	20060301,20060601)
GO
ALTER DATABASE AdventureworksDW2016CTP3 SET compatibility_level = 130
GO
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO
