
USE AdventureWorks2017
GO
--بررسی جهت وجود جدول 
IF OBJECT_ID('SalesOrderHeader2')>0
	DROP TABLE SalesOrderHeader2
GO
--تهیه کپی از جدول
SELECT * INTO SalesOrderHeader2 FROM Sales.SalesOrderHeader
GO
--ایجاد یک کلاستر ایندکس
CREATE CLUSTERED INDEX Clustered_Index ON SalesOrderHeader2(SalesOrderID)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX SalesOrderHeader2
GO
--مشاهده پلن اجرایی
SELECT SalesOrderID, OrderDate, Status, TerritoryID
	FROM SalesOrderHeader2
		WHERE OrderDate = '2013-08-02'
GO
--ایجاد یک کلاستر ایندکس فرضی
--Hypothetical Index
--شما است Session صرفا به ازای
 CREATE INDEX IX_OrderDate ON SalesOrderHeader2 (OrderDate)
	INCLUDE (Status,TerritoryID)
	 WITH STATISTICS_ONLY = -1
/*
WITH STATISTICS_ONLY = 0 :  Just Index
WITH STATISTICS_ONLY = -1 : Index With Statistics
*/
SP_HELPINDEX SalesOrderHeader2
GO
--مشاهده پلن اجرایی
--بررسی شود که آیا از ایندکس جدید استفاده شده است
SELECT SalesOrderID, OrderDate, Status, TerritoryID
	FROM SalesOrderHeader2
		WHERE OrderDate = '2013-08-02'
GO
SELECT SalesOrderID, OrderDate, Status, TerritoryID
	FROM SalesOrderHeader2 WITH(INDEX(IX_OrderDate))
		WHERE OrderDate = '2013-08-02'
GO
--Hypothetical مشاهده لیست ایندکس های از نوع 
/*
 Results:
  |DatabaseID    |ObjectID	   |IndexID |
  |7			 |1303675692   |2      |
*/
SELECT DB_ID() AS DatabaseID,object_id AS ObjectID,index_id AS IndexID FROM sys.indexes
	WHERE object_id = OBJECT_ID('SalesOrderHeader2') AND is_hypothetical = 1
GO
--DBCC AUTOPILOT بررسی دستور
DBCC TRACEON (2588)
DBCC HELP('AUTOPILOT')
GO
-- Use typeId 0 to enable a specifc index on AutoPilot mode
SELECT DB_ID('AdventureWorks2017')
DBCC AUTOPILOT(0, 14, 800721905, 3)
GO
SET AUTOPILOT ON
GO
SELECT SalesOrderID, OrderDate, Status, TerritoryID
	FROM SalesOrderHeader2 
		WHERE OrderDate = '2013-08-02'
GO
SET AUTOPILOT OFF
GO
--------------------------------------------------------------------

--RowCount,PageCount به روزرسانی آمارها با استفاده از
--هدف شبیه سازی پلن اجرایی جداول بزرگ
USE Northwind
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('Orders2')>0
	DROP TABLE Orders2
GO
--تهیه کپی از جدول
SELECT * INTO Orders2 FROM Orders
GO
--ایجاد ایندکس به ازای جدول
CREATE CLUSTERED INDEX IX_Clustered ON Orders2(OrderID)
CREATE NONCLUSTERED INDEX IX_ShipCountry ON Orders2(ShipCountry)
GO
--مشاهده پلن اجرایی
SELECT * FROM Orders2
	WHERE ShipCountry='USA'
GO
--های یک جدولStats استخراج لیست
SP_HELPSTATS N'Orders2', 'ALL'
GO
--Stats به روزرسانی
UPDATE STATISTICS Orders2 
	WITH ROWCOUNT  = 1000000 , PAGECOUNT = 100000
GO
UPDATE STATISTICS Orders2 IX_ShipCountry
	WITH ROWCOUNT  = 1000000 , PAGECOUNT = 100000
GO
--مشاهده آمار رکوردها و تعداد صفحات
SELECT * FROM sys .partitions
	WHERE object_id = object_id('dbo.Orders2')
go
SELECT * FROM sys .dm_db_partition_stats
WHERE object_id = object_id('dbo.Orders2')
GO
DBCC FREEPROCCACHE
--مشاهده پلن اجرایی
SELECT * FROM Orders2
	WHERE ShipCountry='USA'
GO
