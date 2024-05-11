

/*
sys.dm_db_index_usage_stats
*/
--------------------------------------
--Header Columns
/*
--شامل فیلدهای زیر می باشد
database_id : ID of the database in which the table or view is defined
object_id   : ID of the table or view in which the index is defined
index_id    : ID of the index
*/
USE AdventureWorks2017
GO
SELECT * FROM sys.dm_db_index_usage_stats
GO
SELECT  
	OBJECT_NAME(i.object_id) AS table_name
	,i.name AS index_name
	,ius.database_id
	,i.object_id
	,i.index_id
	,ius.*
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id
	AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
WHERE 
	ius.index_id IS NULL AND OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
GO
--------------------------------------
--User Columns
/*
--شامل فیلدهای زیر می باشد
user_seeks    : Aggregate count of seeks by user queries.
user_scans    : Aggregate count of scans by user queries
user_lookups  : Aggregate count of bookmark/key lookups by user queries
user_updates  : Aggregate count of updates by user queries
last_user_seek : Date and time of last user seek
last_user_scan : Date and time of last user scan
last_user_lookup : Date and time of last user lookup
last_user_update : Date and time of last user update
*/
--------------------
--user_seeks
USE AdventureWorks2017
GO
--استخراج پلن اجرایی واقعی
--Actual Execution Plan
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659
GO
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID BETWEEN 43659 AND 44659
GO
SELECT TOP 10
	OBJECT_NAME(i.object_id) AS table_name
	,i.name AS index_name
	,ius.user_seeks
	,ius.last_user_seek
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats ius
	ON i.object_id = ius.object_id AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
WHERE ius.object_id = OBJECT_ID('Sales.SalesOrderDetail')
GO
--------------------
---user_scans
--استخراج پلن اجرایی واقعی
--Actual Execution Plan
SELECT * FROM Sales.SalesOrderDetail
GO
SELECT * FROM Sales.SalesOrderDetail
	WHERE CarrierTrackingNumber = '4911-403C-98'
GO
SELECT TOP 10
	OBJECT_NAME(i.object_id) AS table_name
	,i.name AS index_name
	,ius.user_scans
	,ius.last_user_scan
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats ius
	ON i.object_id = ius.object_id	AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
WHERE ius.object_id = OBJECT_ID('Sales.SalesOrderDetail')
GO
--------------------
---user_lookup
--استخراج پلن اجرایی واقعی
--Actual Execution Plan
SELECT ProductID, CarrierTrackingNumber
	FROM Sales.SalesOrderDetail
WHERE ProductID = 778
GO
SELECT TOP 10
	OBJECT_NAME(i.object_id) AS table_name
	,i.name AS index_name
	,ius.user_seeks
	,ius.user_lookups
	,ius.last_user_lookup
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats ius
	ON i.object_id = ius.object_id AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
WHERE ius.object_id = OBJECT_ID('Sales.SalesOrderDetail')
GO
--------------------
---user_updates
--استخراج پلن اجرایی واقعی
--Actual Execution Plan
INSERT INTO Sales.SalesOrderDetail
(SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, 
UnitPriceDiscount, ModifiedDate)
SELECT SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, 
UnitPriceDiscount, GETDATE() AS ModifiedDate
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID = 1;
GO
UPDATE Sales.SalesOrderDetail
SET CarrierTrackingNumber = '999-99-9999'
WHERE ModifiedDate > DATEADD(d, -1, GETDATE());
GO
DELETE FROM Sales.SalesOrderDetail
WHERE ModifiedDate > DATEADD(d, -1, GETDATE());
GO
SELECT TOP 10
OBJECT_NAME(i.object_id) AS table_name
,i.name AS index_name
,ius.user_updates
,ius.last_user_update
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats ius
ON i.object_id = ius.object_id
AND i.index_id = ius.index_id
AND ius.database_id = DB_ID()
WHERE ius.object_id = OBJECT_ID('Sales.SalesOrderDetail')
GO
--------------------------------------
--System Columns
/*
--شامل فیلدهای زیر می باشد
system_seeks : Number of seeks by system queries
system_scans : Number of scans by system queries
system_lookups : Number of lookups by system queries
system_updates : Number of updates by system queries
last_system_seek : Time of last system seek
last_system_scan : Time of last system scan
last_system_lookup : Time of last system lookup
last_system_update : Time of last system update
*/
GO
UPDATE Sales.SalesOrderDetail
SET UnitPriceDiscount = 0.00
WHERE UnitPriceDiscount = 0.01
GO
SELECT OBJECT_NAME(i.object_id) AS table_name
,i.name AS index_name
,ius.system_seeks
,ius.system_scans
,ius.system_lookups
,ius.system_updates
,ius.last_system_seek
,ius.last_system_scan
,ius.last_system_lookup
,ius.last_system_update
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats ius
ON i.object_id = ius.object_id
AND i.index_id = ius.index_id
AND ius.database_id = DB_ID()
WHERE ius.object_id = OBJECT_ID('Sales.SalesOrderDetail')
--------------------------------------
/*
پیدا کردن کلید مناسب برای کلاستر ایندکس
*/
USE AdventureWorks2017
GO
--بررسی ایندکس های مربوط به جدول
SP_HELPINDEX 'Person.Address'
GO
/*
ما در سیستم کوئری زیر را زیاد استفاده می کنیم 
هستند StateProvinceID و همچنین کوئری های زیادی داریم که دارای شرط
Show Execution Plan
*/
SELECT 
	AddressLine1, AddressLine2 
FROM Person.Address 
WHERE StateProvinceID = 1
GO
--بررسی وضعیت استفاده ایندکس
SELECT   
	OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME],  
	I.[NAME] AS [INDEX NAME],  
	USER_SEEKS,  
	USER_SCANS,  
	USER_LOOKUPS,  
	USER_UPDATES  
FROM     sys.dm_db_index_usage_stats AS S  
         INNER JOIN sys.indexes AS I  
           ON I.[OBJECT_ID] = S.[OBJECT_ID]  
              AND I.INDEX_ID = S.INDEX_ID  
WHERE    OBJECT_NAME(S.[OBJECT_ID]) = 'Address'
GO
--تصمیم به عوض کردن کلاستر ایندکس