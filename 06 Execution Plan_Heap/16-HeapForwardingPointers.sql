
--بررسی معایب هیپ

--ایجاد بانک اطلاعاتی تستی
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO
--------------------------------------------------------------------
--هنگام به روز رسانی رکوردها Forwarding Pointer مشکل 
USE MyDB2017
GO
--ایجاد یک جدول جدید
DROP TABLE IF EXISTS ForwardingPointers
GO
CREATE TABLE ForwardingPointers
(
	ID int not null,
	Val varchar(8000) null
)
GO
--درج چند رکورد تستی در جدول
INSERT INTO ForwardingPointers(ID,Val) VALUES
	(1,NULL),
	(2,REPLICATE('2',7800)),
	(3,NULL)
GO
--مشاهده رکوردهای موجود در جدول
SELECT * FROM ForwardingPointers
GO
--forwarded_record_count مشاهده 
SELECT 
	page_count, avg_record_size_in_bytes,
	avg_page_space_used_in_percent, forwarded_record_count
FROM sys.dm_db_index_physical_stats(db_id('MyDB2017'),object_id(N'ForwardingPointers'),NULL,NULL,'DETAILED')
GO
--IO مشاهده تعداد 
SET STATISTICS IO ON
SELECT COUNT(*) FROM ForwardingPointers
SET STATISTICS IO OFF
GO
--به روز رسانی رکوردها
UPDATE ForwardingPointers set Val = REPLICATE('1',5000) WHERE ID = 1
UPDATE ForwardingPointers set Val = REPLICATE('3',5000) WHERE ID = 3
GO
--forwarded_record_count مشاهده 
SELECT 
	page_count, avg_record_size_in_bytes,
	avg_page_space_used_in_percent, forwarded_record_count
FROM sys.dm_db_index_physical_stats(db_id('MyDB2017'),object_id(N'ForwardingPointers'),NULL,NULL,'DETAILED')
GO
--IO مشاهده تعداد 
SET STATISTICS IO ON
SELECT COUNT(*) FROM ForwardingPointers
SET STATISTICS IO OFF
GO
