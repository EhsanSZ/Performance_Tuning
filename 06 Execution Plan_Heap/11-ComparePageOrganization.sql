﻿
/*
مقایسه حالت های ذخیره سازی
Heap,Clustered,Columnstore
*/
USE master
GO
IF DB_ID('DemoPageOrganization')>0
BEGIN
	ALTER DATABASE DemoPageOrganization SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DemoPageOrganization
END
GO
RESTORE FILELISTONLY FROM DISK ='C:\Temp\DemoPageOrganization.bak'
GO
RESTORE DATABASE DemoPageOrganization FROM DISK ='C:\Temp\DemoPageOrganization.bak' WITH 
	MOVE 'DemoPageOrganization' TO 'C:\Temp\DemoPageOrganization.mdf',
	MOVE 'DemoPageOrganization_log' TO 'C:\Temp\DemoPageOrganization_log.lmdf',
	STATS=1
GO
--------------------------------------------------------------------
--بررسی جدول و نمایش ایندکس ها
--Object Explorer در 
GO
--------------------------------------------------------------------
USE DemoPageOrganization
GO
--بررسی حجم و تعداد رکوردهای هر کدام از جداول
SP_SPACEUSED ColumnstoreTable
GO
SP_SPACEUSED ClusteredTable
GO
SP_SPACEUSED HeapTable
GO
--------------------------------------------------------------------
/*
اجرای کوئری های تحلیلی مشاهده 
Execution Plan
IO
*/
DBCC DROPCLEANBUFFERS
CHECKPOINT
GO
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
GO
USE DemoPageOrganization
GO
--ColumnstoreTable اجرای کوئری برای جدول 
SELECT  
	OrderDateKey/100,ProductKey,
	COUNT(OrderQuantity) AS COUNT_OrderQuantity,
	SUM(SalesAmount) AS SUM_SalesAmount
FROM ColumnstoreTable
WHERE OrderDateKey BETWEEN 20020701 AND 20030701
GROUP BY (OrderDateKey/100),ProductKey
GO
--ClusteredTable اجرای کوئری برای جدول 
SELECT  
	OrderDateKey/100,ProductKey,
	COUNT(OrderQuantity) AS COUNT_OrderQuantity,
	SUM(SalesAmount) AS SUM_SalesAmount
FROM ClusteredTable
WHERE OrderDateKey BETWEEN 20020701 AND 20030701
GROUP BY (OrderDateKey/100),ProductKey
GO
--HeapTable اجرای کوئری برای جدول 
SELECT  
	OrderDateKey/100,ProductKey,
	COUNT(OrderQuantity) AS COUNT_OrderQuantity,
	SUM(SalesAmount) AS SUM_SalesAmount
FROM HeapTable
WHERE OrderDateKey BETWEEN 20020701 AND 20030701
GROUP BY (OrderDateKey/100),ProductKey
GO

