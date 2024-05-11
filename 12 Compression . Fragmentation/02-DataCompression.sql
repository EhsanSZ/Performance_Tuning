
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
GO
--------------------------------------------------------------------
--None_Compression
--------------------------------------------------------------------
 --بررسی جهت وجود جدول 
DROP TABLE IF EXISTS None_Compression
GO
----None Compressionايجاد جدول به صورت 
CREATE TABLE None_Compression
( 
	Code   INT IDENTITY PRIMARY KEY,
	Family NVARCHAR(700),
	Name   NVARCHAR(700)
)WITH (DATA_COMPRESSION = NONE)
GO
SP_HELPINDEX None_Compression
GO
INSERT INTO None_Compression(Family,Name) VALUES (REPLICATE(N'طاهری*',100),REPLICATE(N'علیرضا*',100))
GO 1000
--------------------------------------------------------------------
--Row_Level_Compression
--------------------------------------------------------------------
 --بررسی جهت وجود جدول 
DROP TABLE IF EXISTS Row_Level_Compression
GO
----Row Compressionايجاد جدول به صورت 
CREATE TABLE Row_Level_Compression
( 
	Code   INT IDENTITY PRIMARY KEY,
	Family NVARCHAR(700),
	Name   NVARCHAR(700)
)WITH (DATA_COMPRESSION = ROW)
GO
SP_HELPINDEX Row_Level_Compression
GO
INSERT INTO Row_Level_Compression(Family,Name)
	 VALUES (REPLICATE(N'طاهری*',100),REPLICATE(N'علیرضا*',100))
GO 1000
--------------------------------------------------------------------
--Page_Level_Compression
--------------------------------------------------------------------
 --بررسی جهت وجود جدول 
DROP TABLE IF EXISTS Page_Level_Compression
GO
--Page Compressionايجاد جدول به صورت 
CREATE TABLE Page_Level_Compression
( 
	Code   INT IDENTITY PRIMARY KEY,
	Family NVARCHAR(700),
	Name   NVARCHAR(700)
)WITH (DATA_COMPRESSION = PAGE)
GO
SP_HELPINDEX Page_Level_Compression
GO
INSERT INTO Page_Level_Compression(Family,Name) VALUES (REPLICATE(N'طاهری*',100),REPLICATE(N'علیرضا*',100))
GO 1000
--------------------------------------------------------------------
--بررسی حجم و تعداد صفحات مربوط به جدول
--------------------------------------------------------------------
SP_SPACEUSED None_Compression
GO
SP_SPACEUSED Row_Level_Compression
GO
SP_SPACEUSED Page_Level_Compression
GO
--dm_db_index_physical_stats استفاده از تابع
SELECT 
	O.object_id,O.name,S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,compressed_page_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID(),NULL,NULL,NULL,'DETAILED') S
	INNER JOIN sys.objects O ON S.object_id=O.object_id
	WHERE S.index_id=1 --AND S.index_level=0
GO
--------------------------------------------------------------------
--و زمان اجرای کوئری هاIO بررسی وضعیت 
--------------------------------------------------------------------
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
DBCC DROPCLEANBUFFERS
CHECKPOINT
GO
SELECT * FROM None_Compression
SELECT * FROM Row_Level_Compression
SELECT * FROM Page_Level_Compression
GO
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
--------------------------------------------------------------------
--عوض کردن روش فشرده سازي يك جدول
--------------------------------------------------------------------
--تغییر روش فشرده سازی جدول
ALTER TABLE Page_Level_Compression REBUILD WITH (DATA_COMPRESSION = ROW)
GO
--dm_db_index_physical_stats استفاده از تابع
SELECT 
	O.object_id,O.name,S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,compressed_page_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID(),NULL,NULL,NULL,'DETAILED') S
	INNER JOIN sys.objects O ON S.object_id=O.object_id
	WHERE S.index_id=1 AND S.index_level=0
GO
--تغییر روش فشرده سازی جدول
ALTER TABLE Page_Level_Compression REBUILD WITH (DATA_COMPRESSION = NONE)
GO
--dm_db_index_physical_stats استفاده از تابع
SELECT 
	O.object_id,O.name,S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,compressed_page_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID(),NULL,NULL,NULL,'DETAILED') S
	INNER JOIN sys.objects O ON S.object_id=O.object_id
	WHERE S.index_id=1 AND S.index_level=0
GO
-----------------------------------------------------------------------------------
--بررسی تاثیر فشرده سازی جدول بر روی ایندکس های آن
--ایندکس هاFragmentation بررسی تاثیر فشرده سازی جدول بر
-----------------------------------------------------------------------------------
USE AdventureWorks2017
GO
--dm_db_index_physical_stats استفاده از تابع
SELECT 
	O.object_id,O.name,S.index_id,IX.name,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,S.avg_fragmentation_in_percent,compressed_page_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID(),OBJECT_ID('Sales.SalesOrderHeader'),NULL,NULL,'DETAILED') S
	INNER JOIN sys.objects O ON S.object_id=O.object_id
	LEFT OUTER JOIN sys.indexes IX ON S.object_id = ix.object_id AND S.index_id = ix.index_id
	WHERE  S.index_level=0
GO
--تغییر روش فشرده سازی جدول
ALTER TABLE Sales.SalesOrderHeader REBUILD WITH (DATA_COMPRESSION = PAGE)

ALTER INDEX IX_TerritoryID ON  Sales.SalesOrderHeader REBUILD 
	WITH(DATA_COMPRESSION=PAGE)

sp_helpindex 'Sales.SalesOrderHeader'

ALTER INDEX ALL ON  Sales.SalesOrderHeader REBUILD WITH (DATA_COMPRESSION = PAGE)
GO
ALTER INDEX ALL ON  Sales.SalesOrderHeader REBUILD WITH (DATA_COMPRESSION = none)
GO

--dm_db_index_physical_stats استفاده از تابع
SELECT 
	O.object_id,O.name,S.index_id,IX.name,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,S.avg_fragmentation_in_percent,compressed_page_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID(),OBJECT_ID('Sales.SalesOrderHeader'),NULL,NULL,'DETAILED') S
	INNER JOIN sys.objects O ON S.object_id=O.object_id
	LEFT OUTER JOIN sys.indexes IX ON S.object_id = ix.object_id AND S.index_id = ix.index_id
	WHERE  S.index_level=0
GO
--تغییر روش فشرده سازی جدول
ALTER TABLE Sales.SalesOrderHeader REBUILD WITH (DATA_COMPRESSION = NONE)
GO
-----------------------------------------------------------------------------------
--فشرده کردن ایندکس های یک جدول
-----------------------------------------------------------------------------------
USE AdventureWorks2017
GO
SP_HELPINDEX 'Sales.SalesOrderHeader'
GO
--dm_db_index_physical_stats استفاده از تابع
SELECT 
	O.object_id,O.name,S.index_id,IX.name,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,S.avg_fragmentation_in_percent,compressed_page_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID(),OBJECT_ID('Sales.SalesOrderHeader'),NULL,NULL,'DETAILED') S
	INNER JOIN sys.objects O ON S.object_id=O.object_id
	LEFT OUTER JOIN sys.indexes IX ON S.object_id = ix.object_id AND S.index_id = ix.index_id
	WHERE  S.index_level=0
GO
--alter index all on table_name rebuild with(DATA_COMPRESSION=page)
--فشرده کردن یک ایندکس از جدول
ALTER INDEX AK_SalesOrderHeader_SalesOrderNumber ON Sales.SalesOrderHeader 
	REBUILD WITH(DATA_COMPRESSION=PAGE)
GO
--فشرده کردن کلیه ایندکس های یک جدول
--Clustered Index + NonClustered Index تاثیر آن بر روی
ALTER INDEX ALL ON Sales.SalesOrderHeader 
	REBUILD WITH(DATA_COMPRESSION=PAGE)
GO
--dm_db_index_physical_stats استفاده از تابع
SELECT 
	O.object_id,O.name,S.index_id,IX.name,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,S.avg_fragmentation_in_percent
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID(),OBJECT_ID('Sales.SalesOrderHeader'),NULL,NULL,'DETAILED') S
	INNER JOIN sys.objects O ON S.object_id=O.object_id
	LEFT OUTER JOIN sys.indexes IX ON S.object_id = ix.object_id AND S.index_id = ix.index_id
	WHERE  S.index_level=0
GO
--غیر فشرده کردن ایندکس های یک جدول
ALTER INDEX ALL ON Sales.SalesOrderHeader 
	REBUILD WITH(DATA_COMPRESSION=NONE)
GO
-----------------------------------------------------------------------------------
--استخراج لیست جداول +ایندکس های فشرده یک بانک اطلاعاتی
-----------------------------------------------------------------------------------
SELECT 
	st.name, ix.name , st.object_id, sp.partition_id, sp.partition_number,
	sp.DATA_COMPRESSION,sp.DATA_COMPRESSION_desc
FROM sys.partitions SP 
	INNER JOIN sys.tables ST ON st.object_id = sp.object_id 
	LEFT OUTER JOIN sys.indexes IX ON sp.object_id = ix.object_id AND sp.index_id = ix.index_id
WHERE sp.DATA_COMPRESSION <> 0
ORDER BY st.name, sp.index_id
GO
-----------------------------------------------------------------------------------
--تخمین حجم تقریبی  فشرده سازی
--sp_estimate_DATA_COMPRESSION_savings
-----------------------------------------------------------------------------------
--estimate : برآورد حجم تقريبي  فشرده سازي
--توجه توسط اين تابع عمليات فشرده سازي انجام نمي شود
/* 
sp_estimate_DATA_COMPRESSION_savings 
      [ @schema_name = ] 'schema_name'  
     , [ @object_name = ] 'object_name' 
    , [@index_id = ] index_id 
     , [@partition_number = ] partition_number 
    , [@DATA_COMPRESSION = ] 'DATA_COMPRESSION' 
*/
USE AdventureWorks2017
GO
--بررسي فضاي اشغال شده توسط جدول فوق
SP_SPACEUSED 'Sales.SalesOrderDetail'
--بررسی ایندکس ها
SP_HELPINDEX 'Sales.SalesOrderDetail'
GO
-- "Row" Level Estimation For All Indexes
EXEC sp_estimate_DATA_COMPRESSION_savings 'Sales', 'SalesOrderDetail', NULL, NULL, 'ROW' ;
GO
-- "Page" Level Estimation For All Indexes
EXEC sp_estimate_DATA_COMPRESSION_savings 'Sales', 'SalesOrderDetail', NULL, NULL, 'PAGE' ;
GO
--ایجاد یک پروسیجر جهت استخراج گزارش فشرده سازی جداول
CREATE PROCEDURE usp_Tables_Compress_Report (@compress_method char(4))
AS 
SET NOCOUNT ON
BEGIN
	DECLARE @schema_name sysname, @table_name sysname
	CREATE TABLE #compress_report_tb 
	(ObjName sysname,
	schemaName sysname,
	indx_ID int,
	partit_number int,
	size_with_current_compression_setting bigint,
	size_with_requested_compression_setting bigint,
	sample_size_with_current_compression_setting bigint,
	sample_size_with_requested_compression_setting bigint)
	DECLARE c_sch_tb_crs cursor for 
	SELECT TABLE_SCHEMA,TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_TYPE LIKE 'BASE%' 
	AND TABLE_CATALOG = upper(db_name())
	OPEN c_sch_tb_crs
	FETCH NEXT FROM c_sch_tb_crs INTO @schema_name, @table_name
	WHILE @@Fetch_Status = 0 
	BEGIN
	INSERT INTO #compress_report_tb
	EXEC sp_estimate_DATA_COMPRESSION_savings
	@schema_name = @schema_name,
	@object_name = @table_name,
	@index_id = NULL,
	@partition_number = NULL,
	@DATA_COMPRESSION = @compress_method 
	FETCH NEXT FROM c_sch_tb_crs INTO @schema_name, @table_name
	END
	CLOSE c_sch_tb_crs 
	DEALLOCATE c_sch_tb_crs
	SELECT schemaName AS [schema_name]
	, ObjName AS [table_name]
	, avg(size_with_current_compression_setting) as avg_size_with_current_compression_setting
	, avg(size_with_requested_compression_setting) as avg_size_with_requested_compression_setting
	, avg(size_with_current_compression_setting - size_with_requested_compression_setting) AS avg_size_saving
	FROM #compress_report_tb
	GROUP BY schemaName,ObjName
	ORDER BY schemaName ASC, avg_size_saving DESC 
	DROP TABLE #compress_report_tb
END
SET NOCOUNT OFF
GO
EXEC usp_tables_compress_report @compress_method = 'PAGE'

-----------------------------------------------------------------------------------
--اسکریپت های مفید درباره فشرده سازی
--فشرده کردن کلیه جدول
--فشرده کردن کلیه ایندکس ها
-----------------------------------------------------------------------------------
USE Northwind
GO
--بررسي دستور زير
EXEC SP_MSFOREACHTABLE @COMMAND1="PRINT '?'"
GO
--فشرده کردن کلیه جداول
EXEC SP_MSFOREACHTABLE @COMMAND1="PRINT '?' ALTER TABLE ? REBUILD WITH(DATA_COMPRESSION=PAGE)" 
GO
--استخراج لیست جداول و ایندکس های فشرده 
--چون جدول فشرده شده صرفا کلاستر ایندکس را داریم
SELECT 
	st.name, ix.name , st.object_id, sp.partition_id, sp.partition_number,
	sp.DATA_COMPRESSION,sp.DATA_COMPRESSION_desc
FROM sys.partitions SP 
	INNER JOIN sys.tables ST ON st.object_id = sp.object_id 
	LEFT OUTER JOIN sys.indexes IX ON sp.object_id = ix.object_id AND sp.index_id = ix.index_id
WHERE sp.DATA_COMPRESSION <> 0
ORDER BY st.name, sp.index_id
GO
--فشرده کردن کلیه ایندکس ها
EXEC SP_MSFOREACHTABLE @COMMAND1="PRINT '?' ALTER INDEX ALL ON ? REBUILD WITH(DATA_COMPRESSION=PAGE)" 
GO
--استخراج لیست جداول و ایندکس های فشرده 
--چون تمام ایندکس ها فشرده شده اند تمام ایندکس ها را داریم
SELECT 
	st.name, ix.name , st.object_id, sp.partition_id, sp.partition_number,
	sp.DATA_COMPRESSION,sp.DATA_COMPRESSION_desc
FROM sys.partitions SP 
	INNER JOIN sys.tables ST ON st.object_id = sp.object_id 
	LEFT OUTER JOIN sys.indexes IX ON sp.object_id = ix.object_id AND sp.index_id = ix.index_id
WHERE sp.DATA_COMPRESSION <> 0
ORDER BY st.name, sp.index_id
GO
-----------------------------------------------------------------------------------
--SSMS بررسی فشرده بررسی
-----------------------------------------------------------------------------------
/*
Page بررسی تاثیر فشرده سازی بر روی حجم رکوردهای موجود در 
SQL Internals
*/
USE MyDB2017
GO
DROP TABLE IF EXISTS TestRowCompression
GO
CREATE TABLE TestRowCompression 
( 
	ItemID INT , 
	ItemName CHAR(50) , 
	DateAdded DATETIME , 
	UnitPrice MONEY , 
	ItemLength DECIMAL , 
	ItemWidth DECIMAL  
) 
WITH ( DATA_COMPRESSION = NONE)
GO
INSERT INTO TestRowCompression  VALUES
	 ( 100000, 'NikAmooz', GETDATE(), '0.75', 0, 0 ),
	 ( 100001, 'www.NikAmooz.com',  GETDATE(), NULL, 1.5, .5 ),
	 ( 12, 'www.NikAmooz.com**MasoudTaheri',  GETDATE(), '500.00', 12, 12 )
GO
SELECT * FROM TestRowCompression
GO
--مشاهده صفحات وابسته به جدول
DBCC IND ('MyDB2017', 'TestRowCompression', 0)
GO
DBCC TRACEON (3604); 
GO
/*
--مشاهده محتوای جدول 
--به رکورد سایز توجه شود 
Record Size
*/
DBCC PAGE ('MyDB2017', 1, 896, 3)
GO
--تغییر نوع فشرده سازی
ALTER TABLE dbo.TestRowCompression REBUILD 
	WITH (DATA_COMPRESSION = ROW)
GO
DBCC IND ('MyDB2017', 'TestRowCompression', 0)
GO
DBCC PAGE ('MyDB2017', 1, 9000, 3)
GO
--تغییر نوع فشرده سازی
ALTER TABLE dbo.TestRowCompression REBUILD 
	WITH (DATA_COMPRESSION = PAGE)
GO
DBCC IND ('MyDB2017', 'TestRowCompression', 0)
GO
DBCC PAGE ('MyDB2017', 1, 912, 3)
GO
-----------------------------------------------------------------------------------
--Update بررسی تاثیر فشرده سازی بر روی دستور 
USE AdventureWorks2017
GO
DROP TABLE IF EXISTS SalesOrderDetail2
GO
SELECT * INTO SalesOrderDetail2 FROM Sales.SalesOrderDetail
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON SalesOrderDetail2(SalesOrderDetailID)
GO
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
UPDATE SalesOrderDetail2 SET CarrierTrackingNumber='NikAmooz'
GO
SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON SalesOrderDetail2(SalesOrderDetailID)
	WITH (DROP_EXISTING=ON,DATA_COMPRESSION=PAGE)
GO
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
UPDATE SalesOrderDetail2 SET CarrierTrackingNumber='NikAmooz'
GO
SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO

/*
--تمرین 1
USE AdventureWorksDW2017
GO
DROP TABLE IF EXISTS FactInternetSales2
GO
SELECT * INTO FactInternetSales2 FROM FactInternetSales
GO

SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.compressed_page_count
FROM SYS.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('FactInternetSales2'),NULL,NULL,'Detailed') S
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON FactInternetSales2(SalesOrderNumber,SalesOrderLineNumber)
	WITH(DATA_COMPRESSION=PAGE)
GO
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.compressed_page_count
FROM SYS.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('FactInternetSales2'),NULL,NULL,'Detailed') S
GO
CREATE INDEX IX_CustomerKey_NonCompress ON FactInternetSales2(CustomerKey)
GO
CREATE INDEX IX_CustomerKey_Compress ON FactInternetSales2(CustomerKey)
	WITH(DATA_COMPRESSION=PAGE)
GO
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.compressed_page_count
FROM SYS.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('FactInternetSales2'),NULL,NULL,'Detailed') S
GO

*/

/*
USE AdventureWorksDW2017
GO
DROP TABLE IF EXISTS FactInternetSales2
GO
SELECT * INTO FactInternetSales2 FROM FactInternetSales
GO
DROP TABLE IF EXISTS FactInternetSales3
GO
SELECT * INTO FactInternetSales3 FROM FactInternetSales
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON FactInternetSales2(SalesOrderNumber,SalesOrderLineNumber)
	WITH(DATA_COMPRESSION=PAGE)
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON FactInternetSales3(SalesOrderNumber,SalesOrderLineNumber)

SELECT * FROM FactInternetSales2
		WHERE ShipDateKey BETWEEN  20110101 AND 20111001
GO
SELECT * FROM FactInternetSales3
		WHERE ShipDateKey BETWEEN  20110101 AND 20111001
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON


UPDATE FactInternetSales2 SET SalesAmount=SalesAmount*2
		WHERE ShipDateKey BETWEEN  20110101 AND 20111001

UPDATE FactInternetSales3 SET SalesAmount=SalesAmount*2
		WHERE ShipDateKey BETWEEN  20110101 AND 20111001


*/