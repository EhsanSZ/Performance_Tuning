
USE master
GO
--Extended Event لیست پکیج های پشتیبانی شده توسط 
--ها و مشتقات آن قرار دارندEvent داخل این پکیج ها 
SELECT * FROM sys.dm_xe_packages
SELECT name, DESCRIPTION FROM sys.dm_xe_packages
GO
--Extended Events لیستی از کلیه اشیاء موجود در 
--target,event,action,message
SELECT * FROM sys.dm_xe_objects
SELECT name, description FROM sys.dm_xe_objects  
	WHERE object_type = 'event'
ORDER BY name
GO
--Extended Events معادل رویدادهای پروفایلر در  
SELECT 
	t.trace_event_id AS 'Trace Event ID', 
	t.name AS 'Trace Event Name',
    x.xe_event_name  AS 'XE Event Name'
FROM  sys.trace_events t
INNER JOIN sys.trace_xe_event_map x
ON t.trace_event_id = x.trace_event_id
GO
--های یک رویداد خاص Event Field پیدا کردن لیستی از 
SELECT  
	c.name, c.description
FROM sys.dm_xe_object_columns c
INNER JOIN sys.dm_xe_objects o on o.name= c.object_name
WHERE   
	o.name = 'sql_statement_starting'
GO
--Actions
--Global Fields بدست آوردن
SELECT
	name, description  
FROM sys.dm_xe_objects 
	WHERE object_type = 'action' AND capabilities_desc IS NULL 
ORDER BY name
GO
--Extended Events مشاهده لیست کامل فیلتر ها در
SELECT 
	name, description 
FROM sys.dm_xe_objects 
WHERE 
	object_type = 'pred_source'
GO
--------------------------------------------------------------------
USE master
GO
IF DB_ID('PageSplitDemo')>0
BEGIN
	ALTER DATABASE PageSplitDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE PageSplitDemo
END
GO
CREATE DATABASE PageSplitDemo
GO
USE PageSplitDemo
GO
CREATE TABLE T1 
(
	ID UNIQUEIDENTIFIER DEFAULT NEWID(), 
	Val1 CHAR(8000), 
	Val2 CHAR(37)
)
--ایجاد یک ایندکس کلاستر بر روی جدول
CREATE CLUSTERED INDEX IX_T1 ON T1(ID)
GO
INSERT T1 (Val1, Val2) VALUES ('X','Y')
GO
--رخ خواهد دادPage Split با اجرای چند بار کد زیر 
INSERT T1 (Val1, Val2)
	 SELECT Val1, Val2 FROM T1
GO
SELECT 
	index_id,index_type_desc,index_depth,index_level,
	avg_fragment_size_in_pages,avg_fragmentation_in_percent 
FROM  SYS.dm_db_index_physical_stats
	(
		DB_ID('PageSplitDemo'),OBJECT_ID('T1'),
		NULL,NULL,'Detailed'
	)
GO
--Memory Grant
SELECT 
	(DimCustomer.FirstName+ ' ' + DimCustomer.LastName ) AS FullName,
	COUNT(*) AS RecCount
FROM FactInternetSales 
INNER JOIN  DimCustomer ON DimCustomer.CustomerKey=FactInternetSales.CustomerKey
GROUP BY
	(DimCustomer.FirstName+ ' ' + DimCustomer.LastName ) 
ORDER BY 	(DimCustomer.FirstName+ ' ' + DimCustomer.LastName ) 
