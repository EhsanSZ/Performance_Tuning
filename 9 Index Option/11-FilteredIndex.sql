
USE AdventureWorks2017
GO
--بررسی وجود جدول
DROP TABLE IF EXISTS SalesOrderHeader
GO
--ایجاد جدول
SELECT * INTO SalesOrderHeader 
	FROM AdventureWorks2017.Sales.SalesOrderHeader
GO
--ایجاد یک کلاستر ایندکس بر روی جدول
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON SalesOrderHeader(SalesOrderID)
GO
--ايجاد يك ايندكس به شكل فيلتر شده
--در اين حالت براي ايندكس مورد نظر شرط ايجاد شده است
CREATE INDEX IX_Filtered ON SalesOrderHeader(CustomerID, AccountNumber, OrderDate)
    WHERE OrderDate>='2012-1-1' AND OrderDate <='2012-12-31'
GO
--ايجاد همان ايندكس بدون حالت فيلتر
CREATE INDEX IX_NonFiltered ON SalesOrderHeader(CustomerID, AccountNumber, OrderDate)
GO
--مقايسه حجم اشغال شده توسط اين دو ايندكس
--بررسی تعداد ظرفیت و تعداد صفحات تخصیص یافته به ازای ایندکس ها
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderHeader'),NULL,NULL,'DETAILED') S
	WHERE index_id>1 AND index_level=0
GO
--Execution Plan بررسی
SET STATISTICS IO ON
GO
SELECT CustomerID, AccountNumber, OrderDate
    FROM SalesOrderHeader  
        WHERE OrderDate BETWEEN '2012-01-01' AND '2012-03-01'
GO
SELECT CustomerID, AccountNumber, OrderDate
    FROM SalesOrderHeader WITH(INDEX(IX_NonFiltered))
        WHERE OrderDate BETWEEN '2012-01-01' AND '2012-03-01'
GO
----------------------------------------------------------------------------------
--ایراد استفاده از این ایندکس
USE tempdb
GO
DROP TABLE IF EXISTS dbo.Data
GO
CREATE TABLE dbo.Data
(
	RecId int not null,
	Processed bit not null,
	/* Other Columns */
)
GO
--ساخت ایندکس کلاستر به ازای جدول
CREATE UNIQUE CLUSTERED INDEX IDX_Data_RecId ON dbo.Data(RecId)
GO
SELECT TOP 1000 
	RecId  /* Other Columns */
FROM dbo.Data
WHERE Processed = 0
ORDER BY RecId
GO
--Filtered NonClustered Index ایجاد
CREATE NONCLUSTERED INDEX IDX_Data_Unprocessed_Filtered
ON dbo.Data(RecId)INCLUDE(Processed)
WHERE Processed = 0
GO
--Plan Cache عدم استفاده در 
SELECT TOP 1000 
	RecId /* Other Columns */
FROM dbo.Data
WHERE Processed = @Processed
ORDER BY RecId
GO
----------------------------------------------------------------------------------
--كاربرد ديگر ايندكس هاي فيلتر شده
--در صورتيكه كد ملي داراي مقدار باشد اين مقدار يكتا باشد
USE tempdb
GO
--بررسی وجود جدول
IF OBJECT_ID('Students')>0
	DROP TABLE Students
GO
--ایجاد جدول
CREATE TABLE Students
(
	ID INT IDENTITY PRIMARY KEY,
	Name NVARCHAR(50),
	Family NVARCHAR(50),
	NationalCode NVARCHAR(20)
)
GO
SP_HELP Students
GO
SP_HELPINDEX Students
GO
INSERT Students(Name, Family, NationalCode) VALUES
    (N'مسعود', N'طاهري', '111-111-111-111'),
    (N'فريد', N'طاهري', NULL),
    (N'مجيد', N'طاهري', '222-222-222-222'),
    (N'علي', N'طاهري', '333-333-333-333'),
    (N'عليرضا', N'نصيري', NULL),
    (N'حامد', N'اكبر مقدم', '444-444-444-444'),
    (N'بهروز', N'اكبري', ''),
    (N'صادق', N'نوري', ''),
    (N'محمد', N'صباغي', NULL)
GO
SELECT * FROM Students
GO
--در صورتيكه كد ملي داراي مقدار باشد اين مقدار يكتا باشد
-- This Will Fail
CREATE UNIQUE NONCLUSTERED INDEX IX1 ON Students(NationalCode)
--CREATE UNIQUE INDEX IX1 ON Students(NationalCode)
GO
--در صورتيكه كد ملي داراي مقدار باشد اين مقدار يكتا باشد
-- This Will Work
CREATE UNIQUE INDEX IX1 ON Students(NationalCode) 
	WHERE (NationalCode <>'' AND  NationalCode IS NOT NULL)
GO
SP_HELPINDEX Students
GO
SELECT * FROM sys.indexes WHERE name='IX1'
GO
-- This Will Be Inserted
INSERT Students(Name, Family, NationalCode)
    VALUES (N'كريم', N'صادقي' , NULL)
GO
-- This Will Be Inserted
INSERT Students(Name, Family, NationalCode)
    VALUES (N'علي', N'شادي' , '')
GO
-- This Will Be Inserted
INSERT Students(Name, Family, NationalCode)
    VALUES (N'محمد', N'اصغري' , '')
GO
-- This Will Be Prevented Because of Duplicate CCNO
INSERT Students(Name, Family, NationalCode)
    VALUES (N'ناصر', N'رادمنش' , '222-222-222-222')
GO