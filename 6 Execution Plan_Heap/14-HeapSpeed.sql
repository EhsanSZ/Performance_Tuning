
--بررسی معایب هیپ
--Heap بررسی واکشی اطلاعات در جداول 
USE MyDB2017
GO
--Buffer Pool پاک کردن
DBCC DROPCLEANBUFFERS
CHECKPOINT
GO
--پیدا کردن یک رکورد خاص
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
--تست واکشی تعدادی  رکورد خاص در جدول هیپ
SELECT * FROM SalesOrderDetail_Heap
	WHERE SalesOrderID=72855
GO
--تست واکشی تعدادی رکورد خاص در جدول کلاستر
SELECT * FROM SalesOrderDetail_Clustered
	WHERE SalesOrderID=72855
GO
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO
--مقایسه شود Executio Plan
GO
--------------------------------------------------------------------
--Buffer Pool پاک کردن
DBCC DROPCLEANBUFFERS
CHECKPOINT
GO
--واکشی کلیه رکوردها
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
--تست واکشی تعدادی  رکورد خاص در جدول هیپ
SELECT * FROM SalesOrderDetail_Heap
GO
--تست واکشی تعدادی رکورد خاص در جدول کلاستر
SELECT * FROM SalesOrderDetail_Clustered
GO
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO
--مقایسه شود Executio Plan
GO
