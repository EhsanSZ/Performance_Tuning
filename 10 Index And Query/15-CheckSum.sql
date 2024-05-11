
USE tempdb
GO
--CHECKSUM آشنایی با تابع
/*
CHECKSUM ( * | expression [ ,...n ] )
*/
--تاثیر حروف بزرگ و کوچک
SELECT CHECKSUM('MasoudTaheri')
SELECT CHECKSUM('MASOUDTAHERI')
SELECT CHECKSUM('masoudtaheri')
GO
--تاثیر چند مقدار
SELECT CHECKSUM('Masoud','Taheri')
SELECT CHECKSUM('MASOUD','TAHERI')
SELECT CHECKSUM('masoud','taheri')
GO
--تاثیر مقدار یونی کد
SELECT CHECKSUM(N'Masoud',N'Taheri')
SELECT CHECKSUM(N'MASOUD',N'TAHERI')
SELECT CHECKSUM(N'masoud',N'taheri')
GO
--------------------------------------------------------------------
USE tempdb
GO
IF OBJECT_ID('Big_Table')>0
	DROP TABLE Big_Table
GO
CREATE TABLE Big_Table
(
    ID BIGINT IDENTITY CONSTRAINT PK_Big_Table PRIMARY KEY,
    Wide_Col VARCHAR(50),
    Wide_Col_CheckSum AS CHECKSUM(Wide_Col) PERSISTED,
    Other_Col INT
)
GO
--ایجاد ایندکس 
CREATE INDEX IX_Wide_Col_CheckSum ON Big_Table (Wide_Col_CheckSum)
CREATE INDEX IX_Wide_Col ON Big_Table (Wide_Col)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX Big_Table
GO
--------------------------------------------------------------------
--درج تعدادی رکورد تستی
SET NOCOUNT ON
DECLARE @count INT = 0
WHILE @count < 10000
BEGIN
    SET @count = @count + 1
    INSERT INTO Big_Table (wide_col, other_col) 
    VALUES (SUBSTRING(master.dbo.fn_varbintohexstr(CRYPT_GEN_RANDOM(25)), 3, 50), @count)
END
GO
--مشاهده رکوردهای درج شده
SELECT * FROM Big_Table
GO
--درج یک رکورد تستی
INSERT INTO Big_Table (wide_col, other_col) 
	VALUES ('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 9999999)
GO
--------------------------------------------------------------------
--Show Execution Plan
SET STATISTICS IO ON 
GO
SELECT * FROM Big_Table 
WHERE 
	wide_col = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
GO
SELECT * FROM Big_Table 
WHERE 
--	wide_col = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' AND 
	wide_col_checksum = CHECKSUM('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
GO
--------------------------------------------------------------------
--بررسی اندازه ایندکس
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Big_Table'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
GO
--------------------------------------------------------------------
--حذف ایندکس
DROP INDEX IX_Wide_Col ON Big_Table
GO
--Show Execution Plan
SET STATISTICS IO ON 
GO
SELECT * FROM Big_Table 
WHERE 
	wide_col = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
GO
SELECT * FROM Big_Table 
WHERE 
	wide_col = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	AND wide_col_checksum = CHECKSUM('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
GO
--------------------------------------------------------------------
--Index Size SQL Server 2016
DROP TABLE IF EXISTS dbo.t1
GO
CREATE TABLE dbo.t1
( c1 VARCHAR(1700)
)
GO
CREATE INDEX ix_c1 ON dbo.t1(c1)
GO
INSERT t1 VALUES (REPLICATE('1', 1700))
GO