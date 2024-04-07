--------------------------------------------------------------------
USE master
GO
IF DB_ID('DemoPageOrganization')>0
BEGIN
	ALTER DATABASE DemoPageOrganization SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DemoPageOrganization
END
GO
RESTORE FILELISTONLY FROM DISK ='C:\Temp\DemoPageOrganization.bak'
GO
RESTORE DATABASE DemoPageOrganization FROM DISK ='C:\Temp\DemoPageOrganization.bak' WITH 
	MOVE 'DemoPageOrganization' TO 'C:\Temp\DemoPageOrganization.mdf',
	MOVE 'DemoPageOrganization_log' TO 'C:\Temp\DemoPageOrganization_log.lmdf',
	STATS=1
GO
USE DemoPageOrganization
GO
--------------------------------------------------------------------
USE DemoPageOrganization
GO
--Segment بررسی 
--سگمنت ها به ازای ستون ها هستند
SELECT 
	* 
FROM sys.column_store_segments
GO
--ها Row Group بررسی 
SELECT 
	OBJECT_NAME(object_id),* 
FROM sys.column_store_row_groups
GO
--بررسی سگمنت ها
SELECT 
	p.partition_number as [partition], c.name as [column], s.column_id, s.segment_id
	,p.data_compression_desc as [compression], s.version, s.encoding_type, s.row_count
	,s.has_nulls, s.magnitude,s.primary_dictionary_id, s.secondary_dictionary_id
	,s.min_data_id, s.max_data_id, s.null_value
	,convert(decimal(12,3),s.on_disk_size / 1024.0 / 1024.0) as [Size MB]
FROM sys.column_store_segments s join sys.partitions p on
	p.partition_id = s.partition_id
INNER JOIN sys.indexes i on
	p.object_id = i.object_id
LEFT JOIN sys.index_columns ic on
	i.index_id = ic.index_id and
	i.object_id = ic.object_id and
	s.column_id = ic.index_column_id
LEFT JOIN sys.columns c on
	ic.column_id = c.column_id and
	ic.object_id = c.object_id
WHERE 
	i.name = 'IX_ColumnStore'
ORDER BY 
	p.partition_number, s.segment_id, s.column_id
GO
--مشاهده داده های مربوط به دیکشنری 
SELECT 
	* 
FROM sys.column_store_dictionaries 
GO
SELECT 
	p.partition_number as [partition], c.name as [column], d.column_id, d.dictionary_id
	,d.version, d.type, d.last_id, d.entry_count
	,convert(decimal(12,3),d.on_disk_size / 1024.0 / 1024.0) as [Size MB]
from sys.column_store_dictionaries d join sys.partitions p on
p.partition_id = d.partition_id
join sys.indexes i on
p.object_id = i.object_id
left join sys.index_columns ic on
i.index_id = ic.index_id and
i.object_id = ic.object_id and
d.column_id = ic.index_column_id
left join sys.columns c on
ic.column_id = c.column_id and
ic.object_id = c.object_id
where i.name = 'IX_ColumnStore'
ORDER BY p.partition_number, d.column_id
GO
USE DemoPageOrganization
GO
--Columnstore Index بررسی صفحات تخصیص داده شده به
SELECT 
	i.name as [Index], p.index_id, p.partition_number as [Partition]
	,p.data_compression_desc as [Compression], u.type_desc, u.total_pages
FROM sys.partitions p join sys.allocation_units u on
p.partition_id = u.container_id
join sys.indexes i on
p.object_id = i.object_id and p.index_id = i.index_id
WHERE p.object_id = object_id(N'ColumnstoreTable')
GO
--------------------------------------------------------------------
--COLUMNSTORE_ARCHIVE بررسی حالت
USE DemoPageOrganization
GO
--بررسی حجم و تعداد رکوردهای هر کدام از جداول
SP_SPACEUSED ColumnstoreTable
GO
SP_SPACEUSED ClusteredTable
GO
SP_SPACEUSED HeapTable
GO
--بر روی جدول هیپ Clustered Columnstore Index ساخت 
CREATE CLUSTERED COLUMNSTORE INDEX IX_CCI ON HeapTable
	WITH (DATA_COMPRESSION=COLUMNSTORE_ARCHIVE)
GO
SP_SPACEUSED ColumnstoreTable
GO
SP_SPACEUSED ClusteredTable
GO
SP_SPACEUSED HeapTable
GO
--عادی Columnstore اجرای کوئری بر روی 
SELECT  
	OrderDateKey/100,ProductKey,
	COUNT(OrderQuantity) AS COUNT_OrderQuantity,
	SUM(SalesAmount) AS SUM_SalesAmount
FROM ColumnstoreTable
WHERE OrderDateKey BETWEEN 20020701 AND 20030701
GROUP BY (OrderDateKey/100),ProductKey
GO
--آرشیو Columnstore اجرای کوئری بر روی 
SELECT  
	OrderDateKey/100,ProductKey,
	COUNT(OrderQuantity) AS COUNT_OrderQuantity,
	SUM(SalesAmount) AS SUM_SalesAmount
FROM HeapTable
WHERE OrderDateKey BETWEEN 20020701 AND 20030701
GROUP BY (OrderDateKey/100),ProductKey
GO
