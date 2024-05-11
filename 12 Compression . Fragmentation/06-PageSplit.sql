
/*
Page Split بررسي   
*/
USE master
GO
--ساخت بانک اطلاعاتی
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO--بررسی وجود جدول 
DROP TABLE IF EXISTS PageSplitTest
GO
CREATE TABLE PageSplitTest
(
	ID INT  ,
	MyChar CHAR(2000)
)
GO
--ایجاد کلاستر ایندکس
CREATE CLUSTERED INDEX IX_Clustered ON PageSplitTest(ID)
GO
--درج تعدادی رکورد تستی
DECLARE @I INT=0
WHILE(@I< 1000)
BEGIN
	SET  @I+=1
	INSERT INTO PageSplitTest VALUES (@I,'Masoud Taheri')
END
GO
--به روزرسانی تعدادی رکورد
UPDATE PageSplitTest SET MyChar =  REPLICATE('X',900),ID=ID*4
	WHERE ID%5 =1
GO
--درج تعدادی رکورد تستی
DECLARE @I INT=0
WHILE(@I< 1000)
BEGIN
	SET  @I+=1
	INSERT INTO PageSplitTest VALUES (@I,'Masoud Taheri')
END
GO
--Fragmentation بررسی وضعیت 
SELECT
	OBJECT_SCHEMA_NAME(ios.object_id) + '.' + OBJECT_NAME(ios.object_id) as table_name
	,i.name as index_name
	,leaf_allocation_count
	,nonleaf_allocation_count
FROM sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('PageSplitTest'),NULL, NULL) ios
INNER JOIN sys.indexes i ON i.object_id = ios.object_id AND i.index_id = ios.index_id
GO
SELECT
OBJECT_SCHEMA_NAME(ips.object_id) + '.' + OBJECT_NAME(ips.object_id) as table_name
	,ips.avg_fragmentation_in_percent
	,ips.fragment_count
	,page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('PageSplitTest'),NULL, NULL, 'LIMITED') ips
GO
--در لاگ فایلPage Split ثبت 
SELECT
            [Transaction Name]
            ,Description
			,[AllocUnitName]
			,[Operation]
            ,*
FROM FN_DBLOG(NULL,NULL)
	WHERE [Operation] like  N'%SPLIT%' 
GO
SELECT
    [AllocUnitName] AS N'Index',
    (CASE [Context]
        WHEN N'LCX_INDEX_LEAF' THEN N'Nonclustered'
        WHEN N'LCX_CLUSTERED' THEN N'Clustered'
        ELSE N'Non-Leaf'
    END) AS [SplitType],
    COUNT (1) AS [SplitCount]
FROM fn_dblog (NULL, NULL)
	WHERE [Operation] = N'LOP_DELETE_SPLIT'
		GROUP BY [AllocUnitName], [Context];
GO
---
/*
Fragmentation بهترین راه جهت استخراج دستوراتی که باعث
است Extended Event شدن استفاده از 
*/
--------------------------------------------------------------------
--SQL Server 2012,2014,2016در Page Split بهبود الگوریتم 
