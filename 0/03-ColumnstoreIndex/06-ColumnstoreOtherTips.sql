--------------------------------------------------------------------
/*
Columnstore Index سایر نکات و حالت های مربوط به 
*/

/*
NonClustered Columnstore Index ایجاد یک 
بررسی سناریو درج با استفاده از تعداد زیادی کاربر
*/
GO
USE AdventureWorksDW2017
GO
DROP TABLE IF EXISTS dbo.FactInternetSales2
GO
CREATE TABLE dbo.FactInternetSales2
(
	InternetSalesKey INT IDENTITY PRIMARY KEY WITH (DATA_COMPRESSION=PAGE),
	ProductKey int NOT NULL,
	OrderDateKey int NOT NULL,
	CustomerKey int NOT NULL,
	SalesOrderNumber NCHAR(100) NOT NULL,
	SalesOrderLineNumber tinyint NOT NULL,
	OrderQuantity smallint NOT NULL,
	SalesAmount money NOT NULL,
	CustomerPONumber NCHAR(100) NULL
)
GO
--NonClustered Index ایجاد 
CREATE INDEX IX_CustomerKey ON FactInternetSales2(CustomerKey)
	WITH (DATA_COMPRESSION=PAGE)
GO
--درج داده در جدول
INSERT INTO FactInternetSales2
	SELECT 
		ProductKey, 
		OrderDateKey,  
		CustomerKey,  
		SalesOrderNumber,
		SalesOrderLineNumber,
		OrderQuantity,
		SalesAmount,
		CustomerPONumber
	FROM AdventureWorksDW2017..FactInternetSales
GO 40
--------------------------------------
/*
SQL Query Stress استفاده از 
درج رکورد تستی برای بررسی سرعت
200*200
*/
INSERT INTO FactInternetSales2 (ProductKey,OrderDateKey,CustomerKey,SalesOrderNumber,SalesOrderLineNumber,OrderQuantity,SalesAmount,CustomerPONumber)
	VALUES (310,20101229,21768,'SO43697',1,1,3578.27,'123')
GO
--------------------------------------
--NonClustered Columnstore Index ساخت 
DROP INDEX IF EXISTS IX_NCC ON FactInternetSales2
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_NCC ON FactInternetSales2
(
	InternetSalesKey,
	ProductKey, 
	OrderDateKey,  
	CustomerKey,  
	SalesOrderNumber,
	SalesOrderLineNumber,
	OrderQuantity,
	SalesAmount,
	CustomerPONumber
)
GO
--بررسی حجم ایندکس های موجود در جدول
SELECT 
	OBJECT_NAME(i.OBJECT_ID) TableName,
	i.name IndexName,
	SUM(s.used_page_count) / 128.0 IndexSizeinMB
FROM sys.indexes AS i
INNER JOIN sys.dm_db_partition_stats AS S
     ON i.OBJECT_ID = S.OBJECT_ID AND I.index_id = S.index_id
WHERE OBJECT_NAME(i.OBJECT_ID) ='FactInternetSales2'
GROUP BY i.OBJECT_ID, i.name
GO
/*
SQL Query Stress استفاده از 
درج رکورد تستی برای بررسی سرعت
200*200
*/
INSERT INTO FactInternetSales2 (ProductKey,OrderDateKey,CustomerKey,SalesOrderNumber,SalesOrderLineNumber,OrderQuantity,SalesAmount,CustomerPONumber)
	VALUES (310,20101229,21768,'SO43697',1,1,3578.27,'123')
GO
--Delta Store,Delete Bitmap بررسی وضعیت 
SELECT  
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
	OBJECT_NAME(rg.object_id)  = N'FactInternetSales2'
ORDER BY   
	TableName, IndexName,rg.partition_number, rg.row_group_id
GO
ALTER INDEX IX_NCC ON FactInternetSales2 REBUILD
GO
--------------------------------------
--Select بررسی حالت های مختلف 
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
/*
اجرای کوئری بدون شرط
Clustered Index , NonClustered Columnstore Index مقایسه  
*/
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
GO
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
GO
/*
اجرای کوئری با شرط
Clustered Index , NonClustered Columnstore Index مقایسه  
*/
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
WHERE CustomerKey IN (22890,21691,23588)
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
GO
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
WHERE CustomerKey IN (22890,21691,23588)
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
/*
Clustered Columnstore Index ایجاد یک 
Clustered Columnstore Index بر روی یک NonClustered Index ایجاد 
بررسی سناریو درج با استفاده از تعداد زیادی کاربر
*/
GO
USE AdventureWorksDW2017
GO
DROP TABLE IF EXISTS dbo.FactInternetSales2
GO
CREATE TABLE dbo.FactInternetSales2
(
	InternetSalesKey INT IDENTITY,
	ProductKey int NOT NULL,
	OrderDateKey int NOT NULL,
	CustomerKey int NOT NULL,
	SalesOrderNumber NCHAR(100) NOT NULL,
	SalesOrderLineNumber tinyint NOT NULL,
	OrderQuantity smallint NOT NULL,
	SalesAmount money NOT NULL,
	CustomerPONumber NCHAR(100) NULL
)
GO
--درج داده در جدول
INSERT INTO FactInternetSales2
	SELECT 
		ProductKey, 
		OrderDateKey,  
		CustomerKey,  
		SalesOrderNumber,
		SalesOrderLineNumber,
		OrderQuantity,
		SalesAmount,
		CustomerPONumber
	FROM AdventureWorksDW2017..FactInternetSales
GO 40
--بررسی حجم ایندکس های موجود در جدول
SELECT 
	OBJECT_NAME(i.OBJECT_ID) TableName,
	i.name IndexName,
	SUM(s.used_page_count) / 128.0 IndexSizeinMB
FROM sys.indexes AS i
INNER JOIN sys.dm_db_partition_stats AS S
     ON i.OBJECT_ID = S.OBJECT_ID AND I.index_id = S.index_id
WHERE OBJECT_NAME(i.OBJECT_ID) ='FactInternetSales2'
GROUP BY i.OBJECT_ID, i.name
GO
--Clustered Columnstore Index ساخت 
DROP INDEX IF EXISTS IX_CC ON FactInternetSales2
CREATE CLUSTERED COLUMNSTORE INDEX IX_CC ON FactInternetSales2
GO
--بررسی حجم ایندکس های موجود در جدول
SELECT 
	OBJECT_NAME(i.OBJECT_ID) TableName,
	i.name IndexName,
	SUM(s.used_page_count) / 128.0 IndexSizeinMB
FROM sys.indexes AS i
INNER JOIN sys.dm_db_partition_stats AS S
     ON i.OBJECT_ID = S.OBJECT_ID AND I.index_id = S.index_id
WHERE OBJECT_NAME(i.OBJECT_ID) ='FactInternetSales2'
GROUP BY i.OBJECT_ID, i.name
GO
--بر روی جدول Primary Key ایجاد 
ALTER TABLE FactInternetSales2 ADD CONSTRAINT PK_FactInternetSales2 
	PRIMARY KEY (InternetSalesKey)
GO
--NonClustered Index ایجاد 
CREATE INDEX IX_CustomerKey ON FactInternetSales2(CustomerKey)
	WITH (DATA_COMPRESSION=PAGE)
GO
--مشاهده ایندکس های موجود در جدول
SP_HELPINDEX FactInternetSales2
GO
/*
SQL Query Stress استفاده از 
درج رکورد تستی برای بررسی سرعت
200*200
*/
INSERT INTO FactInternetSales2 (ProductKey,OrderDateKey,CustomerKey,SalesOrderNumber,SalesOrderLineNumber,OrderQuantity,SalesAmount,CustomerPONumber)
	VALUES (310,20101229,21768,'SO43697',1,1,3578.27,'123')
GO
--Delta Store,Delete Bitmap بررسی وضعیت 
SELECT  
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
	OBJECT_NAME(rg.object_id)  = N'FactInternetSales2'
ORDER BY   
	TableName, IndexName,rg.partition_number, rg.row_group_id
GO
ALTER INDEX IX_CC ON FactInternetSales2 REBUILD
GO
--------------------------------------
--Select بررسی حالت های مختلف 
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
/*
اجرای کوئری بدون شرط
*/
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
GO
/*
اجرای کوئری با شرط
NonClustered Index استفاده از 
*/
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
WHERE CustomerKey IN (22890,21691,23588)
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
GO
SELECT 
	FactInternetSales2.*
FROM FactInternetSales2
WHERE CustomerKey IN (22890,21691,23588)
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
/*
Filtered NonClustered Columnstore Index ایجاد یک 
بررسی سناریو درج با استفاده از تعداد زیادی کاربر
*/
USE AdventureWorksDW2017
GO
DROP TABLE IF EXISTS dbo.FactInternetSales2
GO
CREATE TABLE dbo.FactInternetSales2
(
	InternetSalesKey INT IDENTITY PRIMARY KEY WITH (DATA_COMPRESSION=PAGE),
	ProductKey int NOT NULL,
	OrderDateKey int NOT NULL,
	CustomerKey int NOT NULL,
	SalesOrderNumber NCHAR(100) NOT NULL,
	SalesOrderLineNumber tinyint NOT NULL,
	OrderQuantity smallint NOT NULL,
	SalesAmount money NOT NULL,
	CustomerPONumber NCHAR(100) NULL
)
GO
--NonClustered Index ایجاد 
CREATE INDEX IX_CustomerKey ON FactInternetSales2(CustomerKey)
	WITH (DATA_COMPRESSION=PAGE)
GO
--درج داده در جدول
INSERT INTO FactInternetSales2
	SELECT 
		ProductKey, 
		OrderDateKey,  
		CustomerKey,  
		SalesOrderNumber,
		SalesOrderLineNumber,
		OrderQuantity,
		SalesAmount,
		CustomerPONumber
	FROM AdventureWorksDW2017..FactInternetSales
GO 40
--------------------------------------
--NonClustered Columnstore Index ساخت 
DROP INDEX IF EXISTS IX_NCC ON FactInternetSales2
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_NCC ON FactInternetSales2
(
	InternetSalesKey,
	ProductKey, 
	OrderDateKey,  
	CustomerKey,  
	SalesOrderNumber,
	SalesOrderLineNumber,
	OrderQuantity,
	SalesAmount,
	CustomerPONumber
)
WHERE (OrderDateKey>=20130101 AND OrderDateKey<=20131231)
GO
--بررسی حجم ایندکس های موجود در جدول
SELECT 
	OBJECT_NAME(i.OBJECT_ID) TableName,
	i.name IndexName,
	SUM(s.used_page_count) / 128.0 IndexSizeinMB
FROM sys.indexes AS i
INNER JOIN sys.dm_db_partition_stats AS S
     ON i.OBJECT_ID = S.OBJECT_ID AND I.index_id = S.index_id
WHERE OBJECT_NAME(i.OBJECT_ID) ='FactInternetSales2'
GROUP BY i.OBJECT_ID, i.name
GO
/*
SQL Query Stress استفاده از 
درج رکورد تستی برای بررسی سرعت
200*200
*/
INSERT INTO FactInternetSales2 (ProductKey,OrderDateKey,CustomerKey,SalesOrderNumber,SalesOrderLineNumber,OrderQuantity,SalesAmount,CustomerPONumber)
	VALUES (310,20101229,21768,'SO43697',1,1,3578.27,'123')
GO
--Delta Store,Delete Bitmap بررسی وضعیت 
SELECT  
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
	OBJECT_NAME(rg.object_id)  = N'FactInternetSales2'
ORDER BY   
	TableName, IndexName,rg.partition_number, rg.row_group_id
GO
ALTER INDEX IX_NCC ON FactInternetSales2 REBUILD
GO
--------------------------------------
--Select بررسی حالت های مختلف 
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
/*
اجرای کوئری بدون شرط
Clustered Index , NonClustered Columnstore Index مقایسه  
*/
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
GO
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
GO
/*
اجرای کوئری با شرط
Clustered Index , NonClustered Columnstore Index مقایسه  
*/
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
WHERE (OrderDateKey>=20130401 AND OrderDateKey<=20131231)
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
GO
SELECT 
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey,
	COUNT(FactInternetSales2.InternetSalesKey) AS RecCount,
	SUM(FactInternetSales2.SalesAmount) AS SumSalesAmount
FROM FactInternetSales2
INNER JOIN DimDate ON	
	FactInternetSales2.OrderDateKey=DimDate.DateKey
WHERE (OrderDateKey>=20130401 AND OrderDateKey<=20131231)
GROUP BY
	DimDate.CalendarYear,
	FactInternetSales2.CustomerKey
OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
/*
بر روی فیلدهای باینری Columnstore ساخت ایندکس
*/
USE NikAmoozDB2017
GO
DROP TABLE IF EXISTS Orders
GO
CREATE TABLE Orders
(
	OrderID INT PRIMARY KEY, 
	CustomerID INT, 
	OrderDate DATETIME, 
	Note NVARCHAR(MAX),
	OrderAttachFile VARBINARY(MAX)
)
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_NCC ON Orders
(
	OrderID, 
	CustomerID, 
	OrderDate,
	Note ,
	OrderAttachFile 
)
GO
DROP TABLE IF EXISTS Orders2
GO
CREATE TABLE Orders2
(
	OrderID INT , 
	CustomerID INT, 
	OrderDate DATETIME, 
	Note NVARCHAR(MAX),
	OrderAttachFile VARBINARY(MAX)
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX IX_CC ON Orders2
GO
