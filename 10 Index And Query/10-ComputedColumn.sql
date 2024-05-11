
USE tempdb
GO
--Computed Column ايجاد جدول بدون داشتن
IF OBJECT_ID('SimpleTable') IS NOT NULL
	DROP TABLE SimpleTable
GO	
CREATE TABLE SimpleTable
(
	C1 INT CONSTRAINT PKEY_SimpleTable PRIMARY KEY,
	C2 NVARCHAR(10),
	C3 NVARCHAR(10)
)
GO
--بررسي ايندكس هاي جدول
SP_HELPINDEX SimpleTable
GO
SET NOCOUNT ON
--پر كردن تعدادي ركورد در جدول
DECLARE @Counter INT =1
WHILE @Counter<=10000
BEGIN
	INSERT INTO SimpleTable	
		VALUES (@Counter,'A'+CAST(@Counter AS VARCHAR(3)),'B'+CAST(@Counter AS VARCHAR(3)))
		SET @Counter+=1							
END
GO
--مشاهده اطلاعات جدول
SELECT * FROM SimpleTable
GO
--Execution Plane بررسي
--Index Scan
SELECT * FROM SimpleTable
	WHERE (C2+C3='A91B91') --به شرط كوئري دقت كنيد
GO
--------------------------------------------------------------------
--Computed Column ايجاد جدول به شكل
IF OBJECT_ID('ComputedColumnTable') IS NOT NULL
	DROP TABLE ComputedColumnTable
GO	
CREATE TABLE ComputedColumnTable
(
	C1 INT CONSTRAINT PKEY_ComputedColumnTable PRIMARY KEY,
	C2 NVARCHAR(10),
	C3 NVARCHAR(10),
	C4 AS (C2+C3) PERSISTED --به اين ستون دقت كنيد
)
GO
--بررسي ايندكس هاي جدول
SP_HELPINDEX ComputedColumnTable
GO
--پر كردن تعدادي ركورد در جدول
DECLARE @Counter INT =1
WHILE @Counter<=10000
BEGIN
	INSERT INTO ComputedColumnTable (C1,C2,C3)
		VALUES (@Counter,'A'+CAST(@Counter AS VARCHAR(3)),'B'+CAST(@Counter AS VARCHAR(3)))
		SET @Counter+=1		
END
GO
--مشاهده اطلاعات جدول
SELECT * FROM ComputedColumnTable
GO
--Execution Plane بررسي
--Index Scan
SELECT C1,C2,C3 FROM ComputedColumnTable
	WHERE (C4='A911B911') --به شرط كوئري دقت كنيد
GO
--ايجاد يك ايندكس بر روي ستون محسباتي 
CREATE NONCLUSTERED INDEX IX01 ON ComputedColumnTable(C4)
GO
--Execution Plane بررسي
--Index Seek
SELECT C1,C2,C3 FROM ComputedColumnTable
	WHERE (C4='A911B911')
GO
--IO فعال سازي آمار 
SET STATISTICS IO ON
GO
--IO مشاهده پلن اجرايي و مشاهده آمار
SELECT C1,C2,C3 FROM SimpleTable
	WHERE (C2+C3='A911B911')
GO
SELECT C1,C2,C3 FROM ComputedColumnTable
	WHERE (C4='A911B911')
GO
--------------------------------------------------------------------
--بررسی حجم ایندکس
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('SimpleTable'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('ComputedColumnTable'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
--------------------------------------------------------------------
--برای پردازش داده ها استفاده نمی کنندParallel Plan ستون های محاسباتی از 
