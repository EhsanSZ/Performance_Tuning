USE AdventureWorksDW2017
GO
DROP TABLE IF EXISTS FactInternetSales2
GO
SELECT * INTO FactInternetSales2 FROM FactInternetSales
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON FactInternetSales2(SalesOrderNumber,SalesOrderLineNumber )
	WITH(DATA_COMPRESSION=PAGE)
GO
CREATE INDEX IX_CustomerKey  ON FactInternetSales2(CustomerKey)
	WITH(DATA_COMPRESSION=PAGE)
GO
SELECT * FROM FactInternetSales2
GO
--336
UPDATE FactInternetSales2 SET SalesAmount=SalesAmount*2
	WHERE ProductKey=310
GO
--49
DELETE FROM FactInternetSales2 WHERE ProductKey=346
GO
SELECT * FROM FactInternetSales2 WHERE CustomerKey=21768
GO
SELECT 
	OBJECT_SCHEMA_NAME(ios.object_id) + '.' + OBJECT_NAME(ios.object_id) AS table_name
	,i.name AS index_name
	,ios.leaf_insert_count
	,ios.leaf_update_count
	,ios.leaf_delete_count
	,ios.leaf_ghost_count,
	*
FROM sys.dm_db_index_operational_stats(DB_ID(),NULL,NULL,NULL) ios
	INNER JOIN sys.indexes i 
		ON i.object_id = ios.object_id AND i.index_id = ios.index_id
WHERE ios.object_id = OBJECT_ID('FactInternetSales2')
GO
---------------------
USE AdventureWorksDW2017
GO
DROP TABLE IF EXISTS FactInternetSales2
GO
SELECT * INTO FactInternetSales2 FROM FactInternetSales
GO
CREATE CLUSTERED COLUMNSTORE INDEX IX_ColumnStore ON FactInternetSales2
GO
CREATE INDEX IX_CustomerKey ON FactInternetSales2(CustomerKey)
	WITH(DATA_COMPRESSION=PAGE)
GO
SP_SPACEUSED FactInternetSales
GO
SP_SPACEUSED FactInternetSales2

SET STATISTICS IO ON 
SELECT 
	ProductKey,
	COUNT(ProductKey)
FROM FactInternetSales
WHERE 
	OrderDateKey BETWEEN  20110101 AND 20110501
GROUP BY ProductKey
GO
SELECT 
	ProductKey,
	COUNT(ProductKey)
FROM FactInternetSales2
WHERE 
	OrderDateKey BETWEEN  20110101 AND 20110501
GROUP BY ProductKey
GO
