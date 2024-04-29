/*
بررسی
Delta Store,Delete Bitmap
*/
USE master
GO
--ساخت بانک اطلاعاتی
IF DB_ID('NikAmoozDB2017')>0
BEGIN
	ALTER DATABASE NikAmoozDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE NikAmoozDB2017
END
GO
CREATE DATABASE NikAmoozDB2017
GO
USE NikAmoozDB2017
GO
--------------------------------------
--بررسی جهت وجود جدو دو پاک کردن آن
DROP TABLE IF EXISTS dbo.CCI
GO
--ایجاد جدول تستی
CREATE TABLE dbo.CCI
(
	Col1 int not null,
	Col2 varchar(4000) not null,
)
GO
--درج دیتا در جدول تستی
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,N6(C) AS -- 1,048,592 ROWS
(
	SELECT 0 FROM N5 AS T1 CROSS JOIN N3 AS T2
	UNION ALL
	SELECT 0 FROM N3
)
,IDs(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N6)
INSERT INTO dbo.CCI(Col1,Col2)
	SELECT 
		ID, 'aaa' 
	FROM IDS
GO
--Columnstore Index ساخت
CREATE CLUSTERED COLUMNSTORE INDEX IDX_CS_CLUST ON dbo.CCI
	WITH (MAXDOP=1)-- یکی از روش های غلبه بر خطای حافظه
GO
/*
درج انجام شده است 
Delta Store,Delete Bitmap بررسی وضعیت 
*/
SELECT  
	'AfterBulkInsert',
	OBJECT_NAME(rg.object_id)   AS TableName,
	I.name                      AS IndexName,
	I.type_desc                 AS IndexType,
	rg.partition_number,
	rg.row_group_id,
	rg.total_rows,
	rg.size_in_bytes,
	rg.deleted_rows,
	rg.[state],
	rg.state_description
FROM	sys.column_store_row_groups AS rg
INNER JOIN sys.indexes AS I
		ON  I.object_id = rg.object_id AND  I.index_id = rg.index_id
WHERE      
	OBJECT_NAME(rg.object_id)  = N'CCI'
ORDER BY   
	TableName, IndexName,rg.partition_number, rg.row_group_id
GO
--------------------------------------
--درج دیتا جدید
INSERT INTO dbo.CCI(Col1,Col2)
	VALUES (2000000,REPLICATE('C',4000)), (2000001, REPLICATE('D',4000))
GO
--Delta Store,Delete Bitmap بررسی وضعیت 
SELECT  
	'AfterTrickleInsert',
	OBJECT_NAME(rg.object_id)   AS TableName,
	I.name                      AS IndexName,
	I.type_desc                 AS IndexType,
	rg.partition_number,
	rg.row_group_id,
	rg.total_rows,
	rg.size_in_bytes,
	rg.deleted_rows,
	rg.[state],
	rg.state_description
FROM	sys.column_store_row_groups AS rg
INNER JOIN sys.indexes AS I
		ON  I.object_id = rg.object_id AND  I.index_id = rg.index_id
WHERE      
	OBJECT_NAME(rg.object_id)  = N'CCI'
ORDER BY   
	TableName, IndexName,rg.partition_number, rg.row_group_id
GO
--------------------------------------
--حذف دیتا قدیمی و دیتای که جدید درج شده است
DELETE FROM dbo.CCI
WHERE Col1 IN
	( 
		100 -- Row group 0
		,16150 -- Row group 0
		,2000000 -- Newly inserted row (Delta Store)
	)
GO
--Delta Store,Delete Bitmap بررسی وضعیت 
SELECT  
	'AfterDelete',
	OBJECT_NAME(rg.object_id)   AS TableName,
	I.name                      AS IndexName,
	I.type_desc                 AS IndexType,
	rg.partition_number,
	rg.row_group_id,
	rg.total_rows,
	rg.size_in_bytes,
	rg.deleted_rows,
	rg.[state],
	rg.state_description
FROM	sys.column_store_row_groups AS rg
INNER JOIN sys.indexes AS I
		ON  I.object_id = rg.object_id AND  I.index_id = rg.index_id
WHERE      
	OBJECT_NAME(rg.object_id)  = N'CCI'
ORDER BY   
	TableName, IndexName,rg.partition_number, rg.row_group_id
GO
--------------------------------------
--به روز رسانی رکوردی که تازه درج شده است
UPDATE dbo.CCI
	SET Col2 = REPLICATE('z',4000)
WHERE Col1 = 2000001; -- Newly inserted row (Delta Store)
GO
SELECT  
	'AfterUpdate',
	OBJECT_NAME(rg.object_id)   AS TableName,
	I.name                      AS IndexName,
	I.type_desc                 AS IndexType,
	rg.partition_number,
	rg.row_group_id,
	rg.total_rows,
	rg.size_in_bytes,
	rg.deleted_rows,
	rg.[state],
	rg.state_description
FROM	sys.column_store_row_groups AS rg
INNER JOIN sys.indexes AS I
		ON  I.object_id = rg.object_id AND  I.index_id = rg.index_id
WHERE      
	OBJECT_NAME(rg.object_id)  = N'CCI'
ORDER BY   
	TableName, IndexName,rg.partition_number, rg.row_group_id
GO
