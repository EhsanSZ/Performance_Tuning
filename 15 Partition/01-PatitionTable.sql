
/*
پارتشین بندی جداول 
*/
--بازیابی نسخه پشتیبان
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('Test_Part')>0
BEGIN
	ALTER DATABASE Test_Part SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test_Part
END
GO
--نمایش لیست فایل های بانک اطلاعاتی
RESTORE FILELISTONLY FROM DISK='C:\DUMP\TestPart.bak'
GO
--بازيابي بانك اطلاعاتي
RESTORE DATABASE Test_Part  FROM DISK='C:\DUMP\TestPart.BAK' WITH 
	FILE=1,
	MOVE 'Test_Part' TO 'C:\DUMP\TestPart.MDF',
	MOVE 'Test_Part_log' TO 'C:\DUMP\Test_Part_log.LDF',
	STATS=1,REPLACE
GO
USE Test_Part
GO
--------------------------------------------------------------------
--بررسي تعداد ركوردها و فضاي اشغال شده توسط جدول
SP_SPACEUSED 'OrderHeader'
GO
SP_SPACEUSED 'OrderHeader2'
GO   
SP_SPACEUSED 'OrderHeader3'
GO          
--بررسی ایندکس های موجود در جدول
SP_HELPINDEX 'OrderHeader'
GO
SP_HELPINDEX 'OrderHeader2'
GO
SP_HELPINDEX 'OrderHeader3'
GO
--بررسي ساختار جدول فروش و مشاهده فيلد تاريخ سفارش
SP_HELP 'OrderHeader'
GO
--آمار دیتا
--استخراج سال هاي موجود در جدول فروش
SELECT 
	DATEPART(YEAR,OrderDate) AS [Year]  ,COUNT(SalesOrderID) AS [RecCount]
FROM OrderHeader GROUP BY  DATEPART(YEAR,OrderDate)
ORDER BY DATEPART(YEAR,OrderDate)
GO
--مشاهده حداقل و حداكثر تاريخ هاي سفارش
SELECT 
	MIN(OrderDate) AS [Min],
	MAX(OrderDate) AS [Max] 
FROM OrderHeader 
GO
--DateTimeنكته اي در مورد نوع داده
--دقت اين متغيير در حد هزارم ثانيه است
--يادآوري
DECLARE @D DATETIME
SET @D='2018-12-31 23:59:59.997'
SELECT @D AS [Value],DATALENGTH(@D) AS [Length]
GO
--------------------------------------------------------------------
--اضافه كردن فايل گروه به تعداد مورد نياز به بانك اطلاعاتي
ALTER DATABASE Test_Part ADD FILEGROUP FG2001
ALTER DATABASE Test_Part ADD FILEGROUP FG2002
ALTER DATABASE Test_Part ADD FILEGROUP FG2003
ALTER DATABASE Test_Part ADD FILEGROUP FG2004
ALTER DATABASE Test_Part ADD FILEGROUP FG2005
GO
--مشاهده فايل گروه ها
SELECT * FROM sys.filegroups
GO
SP_HELPFILEGROUP
GO
--اضافه شدن ديتا فايل به فايل گروه ها
ALTER DATABASE Test_Part
	ADD FILE (NAME=Data2001,FILENAME='C:\DUMP\Data2001.ndf') TO FILEGROUP FG2001
GO
ALTER DATABASE Test_Part
	ADD FILE (NAME=Data2002,FILENAME='C:\DUMP\Data2002.ndf') TO FILEGROUP FG2002
GO
ALTER DATABASE Test_Part
	ADD FILE (NAME=Data2003,FILENAME='C:\DUMP\Data2003.ndf') TO FILEGROUP FG2003
GO
ALTER DATABASE Test_Part
	ADD FILE (NAME=Data2004,FILENAME='C:\DUMP\Data2004.ndf') TO FILEGROUP FG2004
GO
ALTER DATABASE Test_Part
	ADD FILE (NAME=Data2005,FILENAME='C:\DUMP\Data2005.ndf') TO FILEGROUP FG2005
GO
--استخراج اطلاعاتي در مورد فايل هاي داده
SELECT * FROM sys.database_files
SP_HELPFILE
GO
-----------------------------------------------------------------------
/*
Partition Function ایجاد 
*/
USE Test_Part
GO
--اولين مقدار به معناي بالاترين حد پارتيشن اول است
/*
CREATE PARTITION FUNCTION PF1 (DATETIME)
AS RANGE LEFT
FOR VALUES('20011231 23:59:59:997','20021231 23:59:59:997',
		   '20031231 23:59:59:997','20041231 23:59:59:997')
GO
*/
--اولين مقدار به معناي پايين ترين حد پارتيشن دوم است
CREATE PARTITION FUNCTION PF1 (DATETIME)
AS RANGE RIGHT
FOR VALUES('20020101 00:00:00:000','20030101 00:00:00:000',
		   '20040101 00:00:00:000','20050101 00:00:00:000')
GO 
/*
P1 : 1752-01-01   TO 2001-12-31
P2 : 2002-01-01 TO 2002-12-31
*/
-----------------------------------------------------------------------
/*
Partition Scheme ایجاد 
*/
--حالت اول ايجاد شود
--حالت 1 
CREATE PARTITION SCHEME PS1 AS PARTITION PF1
	TO (FG2001,FG2002,FG2003,FG2004,FG2005)
GO	
/*
--حالت 2 
CREATE PARTITION SCHEME PS1 AS PARTITION PF1
	TO (FG2001,FG2001,FG2003,FG2004,FG2003)
GO
--حالت 3 
CREATE PARTITION SCHEME PS1 AS PARTITION PF1
	ALL TO (FG2001)
*/
--------------------------------------------------------------------
--بازيابي اطلاعات تابع پارتيشن بندي
SELECT * FROM sys.partition_functions 
--بازيابي اطلاعاتي درباره پارامتر تابع پارتيشن بندي
SELECT * FROM sys.partition_parameters 
--بازيابي اطلاعاتي درباره بازه مقادير هر كدام از پارتيشن ها
SELECT * FROM sys.partition_range_values 
GO
--------------------------------------------------------------------
/*
$Partition استفاده از آبجکت 
*/
--بررسي محل قرار گيري داده در كدام پارتيشن است
SELECT $PARTITION.PF1('1999') AS [PartitionNO]
SELECT $PARTITION.PF1('2000') AS [PartitionNO]
SELECT $PARTITION.PF1('2001') AS [PartitionNO]
SELECT $PARTITION.PF1('2001-12-31 23:59:59:997') AS [PartitionNO]
SELECT $PARTITION.PF1('2001-12-31 23:59:59:998') AS [PartitionNO]--Change To 2001-12-31 23:59:59:997
SELECT $PARTITION.PF1('2001-12-31 23:59:59:999') AS [PartitionNO]
SELECT $PARTITION.PF1('2002') AS [PartitionNO]
SELECT $PARTITION.PF1('2002-12-31 23:59:59:997') AS [PartitionNO]
SELECT $PARTITION.PF1('2002-12-31 23:59:59:998') AS [PartitionNO]--Change To 2002-12-31 23:59:59:997
SELECT $PARTITION.PF1('2002-12-31 23:59:59:999') AS [PartitionNO]
SELECT $PARTITION.PF1('2003') AS [PartitionNO]
SELECT $PARTITION.PF1('2004') AS [PartitionNO]
SELECT $PARTITION.PF1('2005') AS [PartitionNO]
SELECT $PARTITION.PF1('2006') AS [PartitionNO]
SELECT $PARTITION.PF1('2010') AS [PartitionNO]
SELECT $PARTITION.PF1('2010-12-31 23:59:59:997') AS [PartitionNO]
SELECT $PARTITION.PF1('2010-12-31 23:59:59:998') AS [PartitionNO]--Change To 2010-12-31 23:59:59:997
SELECT $PARTITION.PF1('2010-12-31 23:59:59:999') AS [PartitionNO]
GO
--تنظيم جدول براي پذيرفتن مقدار نال
ALTER TABLE OrderHeader  ALTER COLUMN OrderDate DATETIME NULL
GO
UPDATE OrderHeader SET OrderDate=NULL WHERE SalesOrderID=43662
GO
--در آن قرار گرفته توجه كنيدNull به پارتيشني كه مقدار 
--هميشه در سمت چپ ترين پارتيشن قرار مي گيرد مگر اينكه خودش يك پارتيشن باشدNull 
SELECT $PARTITION.PF1(OrderDate) AS [Partition Number],OrderHeader.* 
	FROM OrderHeader
GO
--بازگرداندن مقدار به حالت قبل
UPDATE OrderHeader SET OrderDate='2001-07-01 00:00:00.000' WHERE OrderDate IS NULL
ALTER TABLE OrderHeader  ALTER COLUMN OrderDate DATETIME NOT NULL
GO
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT $PARTITION.PF1(OrderDate) AS [Partition Number]
      , MIN(OrderDate) AS [Min Order Date]
      , MAX(OrderDate) AS [Max Order Date]
      , COUNT(SalesOrderID) AS [Rows In Partition]
FROM OrderHeader
	GROUP BY $PARTITION.PF1(OrderDate)
		ORDER BY [Partition Number]
GO
------------------------------------------------------------------
--تبديل جدول غير پارتيشني به جدول پارتشيشن شده 

--استخراج اطلاعاتي درباره جدول
--PK
SP_HELPindex 'OrderHeader'
GO
--Primary Key حذف 
--دقت شودObject Explorer به قسمت ايندكس ها در 
ALTER TABLE OrderHeader DROP CONSTRAINT PK_OrderHeader
GO
ALTER TABLE OrderHeader ADD CONSTRAINT PK_OrderHeader PRIMARY KEY NONCLUSTERED 
(	
	SalesOrderID
)
GO
--ايجاد يك ايندكس پارتيشن بندي شده جديد
--دقت شودObject Explorer به قسمت ايندكس ها در 
CREATE UNIQUE CLUSTERED INDEX IX_Cluster ON
	 OrderHeader(OrderDate,SalesOrderID)ON PS1(OrderDate)
GO
/*
--قانون : اگر ايندكس از نوع پارتيشن بندي باشد بايد كليد پارتيشن بندي به آن اضافه گردد
*/
/*
--ایجاد جدول به صورت پارتیشن شده
--می باشد Align ایندکس 
CREATE TABLE OrderHeader_Merge
(
	SalesOrderID int IDENTITY(1,1) NOT NULL ,
	RevisionNumber tinyint NOT NULL,
	OrderDate datetime NOT NULL,
	ShipDate datetime NULL,
	CONSTRAINT PK_OrderHeader_Merge PRIMARY KEY CLUSTERED (SalesOrderID,OrderDate) 
		ON PS_OrderDate(OrderDate)
)ON PS_OrderDate(OrderDate)
GO
*/
--------------------------------------------------------------------
GO
--بررسی نحوه توزیع داده ها در جدول
SELECT 
	OBJECT_NAME(i.object_id) as Object_Name,
	p.partition_number, fg.name AS Filegroup_Name, rows, au.total_pages,
	CASE 
		boundary_value_on_right WHEN 1 THEN 'less than' 
		ELSE 'less than or equal to' 
	END as 'comparison', value
FROM sys.partitions p JOIN sys.indexes i 
	ON p.object_id = i.object_id and p.index_id = i.index_id
INNER JOIN sys.partition_schemes ps 
	ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions f 
	ON f.function_id = ps.function_id
LEFT JOIN sys.partition_range_values rv 
	ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
INNER JOIN sys.destination_data_spaces dds 
	ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg 
	ON dds.data_space_id = fg.data_space_id
INNER JOIN (SELECT container_id, sum(total_pages) as total_pages FROM sys.allocation_units GROUP BY container_id) AS au 
	ON au.container_id = p.partition_id
WHERE 
	i.index_id <2;
GO
--------------------------------------------------------------------
--Show Execution Plan
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
SELECT * FROM OrderHeader WHERE SalesOrderID=63886 --جدول پارتيشن شده بر اساس تاریخ 
SELECT * FROM OrderHeader2 WHERE SalesOrderID=63886 --جدول پارتيشن نشده - مرتب سازی با آی دی
SELECT * FROM OrderHeader3 WHERE SalesOrderID=63886 --جدول پارتيشن نشده - مرتب سازی با تاریخ
GO
--------------------------------------------------------------------
--جدول پارتيشن شده بر اساس تاریخ 
SELECT * FROM OrderHeader WHERE SalesOrderID=63886 
	AND $PARTITION.PF1(OrderDate)= $PARTITION.PF1('2004-02-10 00:00:00.000')
GO
 
--جدول پارتيشن نشده - مرتب سازی با آی دی
SELECT * FROM OrderHeader2 WHERE SalesOrderID=63886 
GO
--جدول پارتيشن نشده - مرتب سازی با تاریخ
SELECT * FROM OrderHeader3 WHERE SalesOrderID=63886 
GO
--------------------------------------------------------------------
--جدول پارتيشن شده بر اساس تاریخ 
SELECT * FROM OrderHeader WHERE  
	OrderDate BETWEEN '2001-01-01 00:00:00.000' AND '2003-12-31 23:59:59:997'
	AND ShipDate='2003-07-15 00:00:00.000' 
GO
--جدول پارتيشن نشده - مرتب سازی با آی دی
SELECT * FROM OrderHeader2 WHERE  
	OrderDate BETWEEN '2003-01-01 00:00:00.000' AND '2003-12-31 23:59:59:997'
	AND ShipDate='2003-07-15 00:00:00.000' 
GO
--جدول پارتيشن نشده - مرتب سازی با تاریخ
SELECT * FROM OrderHeader3 WHERE 
	OrderDate BETWEEN '2003-01-01 00:00:00.000' AND '2003-12-31 23:59:59:997'
	AND ShipDate='2003-07-15 00:00:00.000'
GO	 
--------------------------------------------------------------------
/*
ترکیب فشرده سازی و پارتیشن بندی
*/
--فشرده کردن پارتیشن ها در حالت های مختلف
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON OrderHeader(OrderDate,SalesOrderID)
WITH
(
    DATA_COMPRESSION = PAGE ON PARTITIONS(1 TO 2),
    DATA_COMPRESSION = NONE ON PARTITIONS(29 TO 31),
    DROP_EXISTING = ON, ONLINE = ON
)
ON PS1(OrderDate)
GO
--به صورت پارتیشن شده Non Clustered Index ایجاد
CREATE NONCLUSTERED INDEX IX_CustomerID
on OrderHeader(CustomerID)
WITH
(
	DATA_COMPRESSION = PAGE ON PARTITIONS(1 TO 28),
	DATA_COMPRESSION = NONE ON PARTITIONS(29 TO 31),
	DROP_EXISTING = ON, ONLINE = ON
)
ON PS1(OrderDate)
GO
--------------------------------------------------------------------
/*
اعمال رایج بر روی پارتیشن ها
*/
GO
--کردن یک پارتیشن خاص Truncate
TRUNCATE TABLE OrderHeader WITH (PARTITIONS (3 TO 5, 7))
GO
--بازسازی آنلاین ایندکس های یک پارتیشن
ALTER INDEX IX_Cluster ON OrderHeader
	REBUILD PARTITION = 1 
WITH (ONLINE= ON)
GO
ALTER INDEX IX_Cluster ON OrderHeader
	REBUILD PARTITION=ALL
WITH (ONLINE= ON)
GO
--فشرده سازی داده های یک پارتیشن خاص
ALTER TABLE OrderHeader REBUILD PARTITION = 1 
	WITH (DATA_COMPRESSION = PAGE)
GO
ALTER TABLE OrderHeader REBUILD PARTITION = ALL
	WITH (DATA_COMPRESSION = PAGE ON PARTITIONS(1,2))
GO
ALTER INDEX IX_Cluster ON OrderHeader 
	REBUILD PARTITION = 3 WITH (DATA_COMPRESSION = PAGE)
GO
ALTER INDEX IX_Cluster ON OrderHeader 
	REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)
GO
--بررسی آمار صفحات قبل از فشرده سازی و بعد از فشرده سازی
SELECT
	partition_number,index_level
	,ips.avg_fragmentation_in_percent
	,ips.fragment_count
	,page_count
	,compressed_page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('OrderHeader'),NULL, NULL, 'DETAILED') ips
WHERE IPS.index_id=1
GO
--------------------------------------------------------------------
/*
Lock Escalation بررسی وضعیت 
*/

BEGIN TRANSACTION
--به روز رسانی رکوردها
UPDATE  OrderHeader SET
	Comment='www.NikAmooz.com'
WHERE 
	OrderDate BETWEEN '2003-01-01 00:00:00.000' AND '2003-12-31 23:59:59:997'
	--AND ShipDate='2003-07-15 00:00:00.000'
GO	
--بررسی وضعیت لاک رکوردها
SELECT 
	[partition_id], [object_id], [index_id], [partition_number]
FROM sys.partitions WHERE object_id = OBJECT_ID ('OrderHeader');
GO 
SELECT 
	[resource_type], [resource_associated_entity_id], 
	[request_mode],[request_type], [request_status] 
FROM sys.dm_tran_locks WHERE [resource_type] <> 'DATABASE';
GO

--دیگر Session واکشی رکوردهای در 
SELECT 
	* 
FROM OrderHeader
	WHERE OrderDate BETWEEN '2002-01-01 00:00:00.000' AND '2002-12-31 23:59:59:997'
GO
ROLLBACK TRANSACTION
GO
-----------------------------
--به ازای پارتیشن LOCK_ESCALATION = AUTO  فعال کردن 
ALTER TABLE OrderHeader SET (LOCK_ESCALATION = AUTO);
GO 
BEGIN TRANSACTION
--به روز رسانی رکوردها
UPDATE  OrderHeader3 SET
	Comment='www.NikAmooz.com'
WHERE 
	OrderDate BETWEEN '2003-01-01 00:00:00.000' AND '2003-12-31 23:59:59:997'
	--AND ShipDate='2003-07-15 00:00:00.000'
GO	
--بررسی وضعیت لاک رکوردها
SELECT 
	[partition_id], [object_id], [index_id], [partition_number]
FROM sys.partitions WHERE object_id = OBJECT_ID ('OrderHeader');
GO 
SELECT 
	[resource_type], [resource_associated_entity_id], 
	[request_mode],[request_type], [request_status] 
FROM sys.dm_tran_locks WHERE [resource_type] <> 'DATABASE';
GO
--دیگر Session واکشی رکوردهای در 
SELECT 
	* 
FROM OrderHeader
	WHERE OrderDate BETWEEN '2002-01-01 00:00:00.000' AND '2002-12-31 23:59:59:997'
GO
ROLLBACK TRANSACTION
GO
--------------------------------------------------------------------
/*
برسی کسب اطلاعات بیشتر در خصوص پارتیشن بندی به 
این فیلم آموزشی مراجعه کنید
http://nikamooz.com/product/data-partitioning-sql-server-2016/
*/
--------------------------------------------------------------------