
--NonClustered Index انتخاب کلید مناسب برای 
USE AdventureWorks2017
GO
--بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS SalesOrderHeader2
GO
--تهیه کپی از جدول
SELECT * INTO SalesOrderHeader2 FROM Sales.SalesOrderHeader
GO
--ایجاد ایندکس کلاستر
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON SalesOrderHeader2(SalesOrderID)
GO
--بررسی مقادیر کلید ایندکس
SELECT COUNT(*) FROM SalesOrderHeader2
SELECT  OrderDate,COUNT(*) FROM Sales.SalesOrderHeader GROUP BY OrderDate 
SELECT  OnlineOrderFlag,COUNT(*) FROM Sales.SalesOrderHeader GROUP BY OnlineOrderFlag 
SELECT  RevisionNumber,COUNT(*) FROM Sales.SalesOrderHeader GROUP BY RevisionNumber 
GO
--NonClustered ایجاد ایندکس های
CREATE INDEX IX_OrderDate ON SalesOrderHeader2(OrderDate)
CREATE INDEX IX_OnlineOrderFlag ON SalesOrderHeader2(OnlineOrderFlag)
CREATE INDEX IX_RevisionNumber ON SalesOrderHeader2(RevisionNumber)
GO
--بررسی وضعیت استفاده از ایندکس ها
SELECT * FROM SalesOrderHeader2 WHERE OrderDate='2014-01-05'
GO
SELECT * FROM SalesOrderHeader2 WHERE OnlineOrderFlag=0
SELECT * FROM SalesOrderHeader2 WHERE OnlineOrderFlag=1
GO
SELECT * FROM SalesOrderHeader2 WHERE RevisionNumber=9
SELECT * FROM SalesOrderHeader2 WHERE RevisionNumber=8
GO
/*
کردن ایندکس برای استفاده Force بررسی دلیل عدم استفاده و 
*/

GO
/*
تشکیل سطوح ایندکس در فضایی جداگانه
آنالیز ایندکس
*/
SELECT 
	index_type_desc,index_id,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderHeader2'),
	NULL,
	NULL,
	'DETAILED'
)
GO