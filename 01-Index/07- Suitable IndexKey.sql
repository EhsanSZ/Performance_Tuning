
USE AdventureWorks2017;
GO

DROP TABLE IF EXISTS SalesOrderHeader2;
GO
-- تهیه کپی از جدول
SELECT * INTO SalesOrderHeader2 FROM Sales.SalesOrderHeader;
GO

-- ایجاد ایندکس کلاستر
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON SalesOrderHeader2(SalesOrderID);
GO

-- بررسی مقادیر کاندیداهای کلید ایندکس
SELECT COUNT(*) FROM SalesOrderHeader2;

-- Wide
SELECT 
	OrderDate, COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY OrderDate;

-- Not Wide
SELECT 
	OnlineOrderFlag, COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag;

-- Not Wide
SELECT
	RevisionNumber, COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY RevisionNumber;
GO

-- NonClustered ایجاد ایندکس های
CREATE INDEX IX_OrderDate ON SalesOrderHeader2(OrderDate);
CREATE INDEX IX_OnlineOrderFlag ON SalesOrderHeader2(OnlineOrderFlag);
CREATE INDEX IX_RevisionNumber ON SalesOrderHeader2(RevisionNumber);
GO

-- بررسی وضعیت استفاده از ایندکس ها
SET STATISTICS IO ON;
GO

-- Wide
SELECT * FROM SalesOrderHeader2
	WHERE OrderDate = '2014-01-05';
GO

-- Not Wide
SELECT * FROM SalesOrderHeader2
	WHERE OnlineOrderFlag = 0;
SELECT * FROM SalesOrderHeader2
	WHERE OnlineOrderFlag = 1;
GO

-- Wide
SELECT * FROM SalesOrderHeader2
	WHERE RevisionNumber = 9;
-- Not Wide
SELECT * FROM SalesOrderHeader2
	WHERE RevisionNumber = 8;
GO