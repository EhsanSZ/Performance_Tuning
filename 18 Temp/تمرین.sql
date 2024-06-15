USE AdventureWorksDW2017
GO
SELECT * INTO #FactInternetSales1 FROM FactInternetSales
go
--TempDb جاری در Session صفحات استفاده شده
SELECT 
	user_objects_alloc_page_count,
	user_objects_dealloc_page_count 
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO

DROP TABLE #FactInternetSales1 
go

--TempDb جاری در Session صفحات استفاده شده
SELECT 
	user_objects_alloc_page_count,
	user_objects_dealloc_page_count 
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO



SELECT * INTO #FactInternetSales1 FROM FactInternetSales
GO
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON #FactInternetSales1
(
	SalesOrderNumber,
	SalesOrderLineNumber
) WITH (DATA_COMPRESSION=PAGE)


SELECT * FROM #FactInternetSales1  F
INNER JOIN AdventureWorks2017..SalesOrderHeader H ON 
	F.SalesOrderNumber=H.SalesOrderNumber 
WHERE H.SalesOrderNumber BETWEEN 'SO43721' AND 'SO43740'


SELECT * INTO #FactInternetSales2 FROM FactInternetSales

SET STATISTICS IO ON 

SELECT * FROM #FactInternetSales1  F
INNER JOIN AdventureWorks2017..SalesOrderHeader H ON 
	F.SalesOrderNumber=H.SalesOrderNumber 
WHERE H.SalesOrderNumber BETWEEN 'SO43721' AND 'SO43740'

SELECT * FROM #FactInternetSales2  F
INNER JOIN AdventureWorks2017..SalesOrderHeader H ON 
	F.SalesOrderNumber=H.SalesOrderNumber 
WHERE H.SalesOrderNumber BETWEEN 'SO43721' AND 'SO43740'

CREATE INDEX IX_CustomerKey ON #FactInternetSales1 (CustomerKey)

SELECT * FROM #FactInternetSales1  F
	where f.CustomerKey =14558
----------------------------------------------------------------

DROP TABLE IF EXISTS FactData_Invalid
GO
CREATE TABLE FactData_Invalid
(
	ID INT IDENTITY  PRIMARY KEY,
	TranDate DATE,
	RRN VARCHAR(10),
	Amount DECIMAL(18,0),
	InsertDate DATETIME
)



GO	
DROP TABLE IF EXISTS FactData


CREATE TABLE FactData
(
	ID INT IDENTITY PRIMARY KEY,
	TranDate DATE,
	RRN VARCHAR(10),
	Amount DECIMAL(18,0)
)
GO
CREATE UNIQUE INDEX IX_RRN ON FactData(RRN) 
	WITH (DATA_COMPRESSION=PAGE,IGNORE_DUP_KEY=ON)
GO
CREATE TYPE TVP_Data AS TABLE
(
	TranDate DATE,
	RRN VARCHAR(10),
	Amount DECIMAL(18,0)
)
GO

CREATE OR ALTER PROCEDURE usp_InsertFactData
(
	@T AS TVP_Data READONLY
)
AS
BEGIN
	BEGIN TRANSACTION
		--درج داده های تکراری
		INSERT FactData_Invalid (TranDate,RRN,Amount,InsertDate)
			SELECT 
				T.TranDate,T.RRN,T.Amount,GETDATE()
			FROM @T T INNER JOIN FactData F ON
				T.RRN=F.RRN

		--درج داده های غیر تکراری
		INSERT INTO FactData (TranDate,RRN,Amount)
			SELECT 
				TranDate,RRN,Amount
			FROM @T

	COMMIT TRANSACTION
END


--------
DECLARE @X TVP_Data
INSERT INTO @X VALUES 
	('2017-01-05','300',25000),
	('2017-02-05','300',15000),
	('2017-01-05','202',250000)
EXEC usp_InsertFactData @X
GO
SELECT * FROM FactData
SELECT * FROM FactData_Invalid


DELETE FROM FactData
DELETE FROM FactData_Invalid