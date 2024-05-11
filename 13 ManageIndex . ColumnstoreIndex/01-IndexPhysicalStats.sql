
USE Northwind
GO
--بررسی جهت وجود جدول 
DROP TABLE IF EXISTS Orders2
GO
--تهیه کپی از جدول
SELECT * INTO Orders2 FROM Orders
GO
--ایجاد ایندکس بر روی جدول
CREATE CLUSTERED INDEX IX_Clustered ON Orders2(OrderID)
CREATE NONCLUSTERED INDEX IX_OrderDate ON Orders2(OrderDate)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX Orders2
GO
/*
sys.dm_db_index_physical_stats
 (
	  { database_id| NULL | 0 | DEFAULT }
	, { object_id| NULL | 0 | DEFAULT }
	, { index_id| NULL | 0 | -1 | DEFAULT }
	, { partition_number| NULL | 0 | DEFAULT }
	, { mode| NULL | DEFAULT } = (DEFAULT,LIMITED,SAMPLED,DETAILED ** DEFAULT=LIMITED)
)

*/
--LIMITED : Leaf Level
SELECT * FROM sys.dm_db_index_physical_stats
(
	DB_ID(),
	OBJECT_ID('Orders2'),
	NULL,
	NULL,
	'LIMITED'
)
GO
--SAMPLED :Leaf Level & نمونه برداری از تعدادی از صفحات
--با توجه به اینکه نمونه برداری انجام می شود احتمال تقریبی بودن نتایج وجود دارد
/*
If the number of leaf level pages is < 10000, read all the pages,
 otherwise read every 100th pages (i.e. a 1% sample)
*/
SELECT * FROM sys.dm_db_index_physical_stats
(
	DB_ID(),
	OBJECT_ID('Orders2'),
	NULL,
	NULL,
	'SAMPLED'
)
GO
--------------------------------------------------------------
--DETAILED: نمایش تمامی سطوح برگ و غیر برگ
SELECT * FROM sys.dm_db_index_physical_stats
(
	DB_ID(),
	OBJECT_ID('Orders2'),
	NULL,
	NULL,
	'DETAILED'
)
GO
--بررسی قسمت های مربوط به این تابع
/*
Header Column : From Database_id To Index_Level
Row Statistics : From page_count To compressed_page_count
Fragmentation Statistics : From avg_fragmentation_in_percent To avg_page_space_used_in_percent
*/
--------------------------------------------------------------
--مقایسه تمام حالت ها با همدیگر
DBCC DROPCLEANBUFFERS
CHECKPOINT
GO
--USE Adventureworks2014
USE AdventureworksDW2016CTP3
GO
DECLARE @Start DATETIME 
DECLARE @First DATETIME 
DECLARE @Second DATETIME 
DECLARE @Third DATETIME 
DECLARE @Finish DATETIME

SET @Start = GETDATE() 
SELECT  * FROM [sys].[dm_db_index_physical_stats](DB_ID(), NULL, NULL, NULL, DEFAULT) AS ddips 
SET @First = GETDATE() 
SELECT  * FROM [sys].[dm_db_index_physical_stats](DB_ID(), NULL, NULL, NULL, 'SAMPLED') AS ddips 
SET @Second = GETDATE() 
SELECT  * FROM [sys].[dm_db_index_physical_stats](DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ddips 
SET @Third = GETDATE() 
SELECT  * FROM [sys].[dm_db_index_physical_stats](DB_ID(), NULL, NULL, NULL, 'DETAILED') AS ddips 
SET @Finish = GETDATE()
SELECT  DATEDIFF(ms, @Start, @First) AS [DEFAULT] , 
        DATEDIFF(ms, @First, @Second) AS [SAMPLED] , 
        DATEDIFF(ms, @Second, @Third) AS [LIMITED] , 
        DATEDIFF(ms, @Third, @Finish) AS [DETAILED]
GO
