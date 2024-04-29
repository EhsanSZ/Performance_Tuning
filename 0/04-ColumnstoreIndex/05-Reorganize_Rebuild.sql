--------------------------------------------------------------------
/*
بازساز ایندکس مثال قبل
*/

USE  NikAmoozDB2017
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
ALTER INDEX ALL ON CCI REBUILD
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