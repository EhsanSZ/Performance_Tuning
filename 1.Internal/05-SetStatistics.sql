
--Set Statistics Time On بررسی 
/*
Parse :دستور Syntax بررسی 
Compile : کامپایل شدن برای ساخت پلن
Execute : اجرای دستور

Execution Time : زمان انتظار برای اجرای دستور تکمیل فعالیت آی او و پردازش داده ها و ارسال آن به کلاینت

CPU Time : زمان واقعی که روی سی پی یو صرف شده است 
Elapsed Time : زمان سپری شده برای کل عملیات

IF CPU Time > Elapsed Time Then (Parallel Process)
تفاوت بین این دو در زمان انتظار در صف برای گرفتن پردازنده و یا انتظار برای تکمیل عملیات آی او
*/
USE AdventureWorks2017
GO
--پاک کردن محتویات کش و حافظه
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
GO
--Dirty Page انتقال محتوای
CHECKPOINT
GO
SET STATISTICS TIME ON
GO
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID=58927
GO
SELECT * FROM Sales.SalesOrderDetail
GO
SET STATISTICS TIME ON
--------------------------
/*
بررسی منوی 
Query -> Query Options
*/
--------------------------------------------------------------------
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE Test01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE IF EXISTS Test01
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE Test01
GO
USE Test01
GO
--بررسی وجود جداول
DROP TABLE IF EXISTS TestTable1
DROP TABLE IF EXISTS TestTable2
GO
--ایجاد جداول تستی
--Heap
CREATE TABLE TestTable1
(
	ID INT IDENTITY,
	FirstName CHAR(3000),
	LastName CHAR(3000)
)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX TestTable1
GO
--Clustered
CREATE TABLE TestTable2
(
	ID INT IDENTITY PRIMARY KEY, --به کلید اصلی دقت کنید
	FirstName CHAR(3000),
	LastName CHAR(3000),
	BlobData NVARCHAR(MAX)
)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX TestTable2
GO
--درج تعدادی رکورد تستی داخل جداول
INSERT INTO TestTable1(FirstName,LastName) VALUES ('Masoud','Taheri')
INSERT INTO TestTable2(FirstName,LastName,BlobData) VALUES ('Masoud','Taheri',REPLICATE('Masoud Taheri**',5000))
GO 1000
--بررسی تعداد رکوردهای درج شده در جداول
SP_SPACEUSED TestTable1
GO
SP_SPACEUSED TestTable2
GO
--به ازی جداول IO انجام عملیات 
--IO وقتی کوئری اجرا می شود عملیات 
SELECT * FROM TestTable1 WHERE ID=500
SELECT * FROM TestTable2 WHERE ID=500
GO
--پاک کردن محتویات کش و حافظه
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
GO
--Dirty Page انتقال محتوای
CHECKPOINT
GO
--IO مشاهده آمار
SET STATISTICS IO ON
GO
--به ازی جدول IO انجام عملیات 
SELECT * FROM TestTable1 WHERE ID=500
SELECT * FROM TestTable2 WHERE ID=500
SELECT * FROM TestTable2 
GO
SET STATISTICS IO OFF
GO
--Scan Count بررسی 
SET STATISTICS IO ON
GO
--Scan count is 0 :(unique index or clustered index Seek)
SELECT * FROM TestTable2 WHERE ID=500
GO
--Scant count is 1 : (non-unique clustered/Heap index Scan)
SELECT * FROM TestTable1 WHERE ID=500
GO
--Scan count is N when N is the number of different seek/scan started towards the left or right side at the leaf level after locating a key value using the index key.
SELECT * FROM TestTable1 WHERE ID IN (500,501,502) -- کلیه پیج های مربوط به ایندکس به یک باره بررسی شده است
SELECT * FROM TestTable2 WHERE ID IN (500,501,502) -- کلیه پیج های مربوط به ایندکس چندین بار بررسی شده است
SELECT * FROM TestTable2 WHERE FirstName IN ('A','B','C') -- کلیه پیج های مربوط به ایندکس به یک باره شده است
GO
/*
Table :
Name of the table.
--------------
Scan count :
Number of seeks/scans started after reaching the leaf level in any direction to retrieve all the values to construct the final dataset for the output.
Scan count is 0 :(unique index or clustered index) if the index used is a unique index or clustered index on a primary key and you are seeking for only one value. For example WHERE Primary_Key_Column = <value>.
Scant count is 1 : (non-unique clustered index) when you are searching for one value using a non-unique clustered index which is defined on a non-primary key column. This is done to check for duplicate values for the key value that you are searching for. For example WHERE Clustered_Index_Key_Column = <value>.
Scan count is N when N is the number of different seek/scan started towards the left or right side at the leaf level after locating a key value using the index key.
--------------
logical reads :
Number of pages read from the data cache.
--------------
physical reads :
Number of pages read from disk.
--------------
read-ahead reads :
Number of pages placed into the cache for the query.
--------------
lob logical reads :
Number of text, ntext, image, or large value type (varchar(max), nvarchar(max), varbinary(max)) pages read from the data cache.
--------------
lob physical reads :
Number of text, ntext, image or large value type pages read from disk.
--------------
lob read-ahead reads :
Number of text, ntext, image or large value type pages placed into the cache for the query.
*/
