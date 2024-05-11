
--Internal Fragmentation , External Fragmentation بررسی 
USE tempdb
GO
DROP TABLE IF EXISTS Positions
GO
CREATE TABLE dbo.Positions
(
	DeviceId INT not null,
	ATime DATETIME2(0) not null,
	Latitude DECIMAL(9,6) not null,
	Longitude DECIMAL(9,6) not null,
	Address NVARCHAR(200) null
)
GO
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT INTO dbo.Positions(DeviceId, ATime, Latitude, Longitude)
    SELECT
                    ID % 100 /*DeviceId*/
                ,DATEADD(MINUTE, -(ID % 657), GETUTCDATE()) /*ATime*/
                    ,0 /*Latitude - just dummy value*/
                    ,0 /*Longitude - just dummy value*/
    FROM IDs;
GO
CREATE UNIQUE CLUSTERED INDEX IDX_Postitions_DeviceId_ATime
ON dbo.Positions(DeviceId, ATime);
GO
--Internal Fragmentation , External Fragmentation بررسی وضعیت 
SELECT 
	index_level, page_count, 
	avg_page_space_used_in_percent, 
	avg_fragmentation_in_percent,fragment_count
FROM sys.DM_DB_INDEX_PHYSICAL_STATS(DB_ID(),OBJECT_ID(N'dbo.Positions'),1,null,'DETAILED')
GO
UPDATE dbo.Positions set Address = N'Position address';
GO
--Internal Fragmentation , External Fragmentation بررسی وضعیت 
SELECT 
	index_level, page_count, 
	avg_page_space_used_in_percent, 
	avg_fragmentation_in_percent,fragment_count
FROM sys.DM_DB_INDEX_PHYSICAL_STATS(DB_ID(),OBJECT_ID(N'dbo.Positions'),1,null,'DETAILED')
GO
--Check SSMS Report
--------------------------------------------------------------------
