
USE AdventureWorks2017;
GO

DROP TABLE IF EXISTS SalesOrderHeader;
GO
-- Heap ایجاد یک جدول از نوع
SELECT * INTO SalesOrderHeader FROM Sales.SalesOrderHeader;
GO

-- بر روی جدول UNIQUE CLUSTERED INDEX ایجاد یک
CREATE UNIQUE CLUSTERED INDEX CIX_SalesOrderID ON SalesOrderHeader(SalesOrderID);
GO

-- Filtered ایجاد ایندکس
CREATE INDEX FIX_CidAccOdate ON SalesOrderHeader(CustomerID,AccountNumber,OrderDate)
    WHERE OrderDate >= '2012-01-01'
	AND OrderDate <= '2012-12-31';
GO

-- NonClustered ایجاد ایندکس
CREATE INDEX NCIX_CidAccOdate ON SalesOrderHeader(CustomerID,AccountNumber,OrderDate);
GO

-- بررسی تعداد صفحات تخصیص داده‌شده به جدول و ایندکس
SELECT 
	index_id, index_type_desc, alloc_unit_type_desc,
	index_depth, index_level, page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderHeader'),
		NULL,NULL,'DETAILED');
GO

-- NonClustered مقايسه تعداد صفحات تخصیص‌یافته به‌ازای ایندکس‌های 
SELECT 
	index_id, index_type_desc, alloc_unit_type_desc,
	index_depth, index_level, page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderHeader'),
		NULL,NULL,'DETAILED')
	WHERE index_type_desc <> 'CLUSTERED INDEX'
	AND index_level = 0;
GO

-- Execution Plan بررسی
SELECT
	CustomerID, AccountNumber, OrderDate
FROM SalesOrderHeader  
	WHERE OrderDate BETWEEN '2012-01-01' AND '2012-03-01';
GO
SELECT
	CustomerID, AccountNumber, OrderDate
FROM SalesOrderHeader  
	WHERE OrderDate BETWEEN '2012-01-01' AND '2013-01-01';
GO

-- مقایسه دو کوئری مشابه با ایندکس‌های متفاوت
SELECT
	CustomerID, AccountNumber, OrderDate
FROM SalesOrderHeader  
	WHERE OrderDate BETWEEN '2012-01-01' AND '2012-03-01';
GO
SELECT
	CustomerID, AccountNumber, OrderDate
FROM SalesOrderHeader WITH(INDEX(NCIX_CidAccOdate))
	WHERE OrderDate BETWEEN '2012-01-01' AND '2012-03-01';
GO
--------------------------------------------------------------------
/*
تمرین کلاسی
:ساختار جدول به‌صورت زیر است

CREATE TABLE Person
(
	ID INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	NationalCode NVARCHAR(20)
);
GO

به‌صورت یکتا باشد اما قابلیت NationalCode می‌خواهیم مقادیر موجود در فیلد
.به‌ازای کاربرانی که فاقد این فیلد هستند وجود داشته باشد NULL یا Blank درج مقادیر
?راه‌کار شما برای انجام این کار چیست

*/

USE WF;
GO

DROP TABLE IF EXISTS Person;
GO

CREATE TABLE Person
(
	ID INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	NationalCode NVARCHAR(20)
);
GO

SP_HELPINDEX Person;
GO

INSERT Person(FirstName, LastName, NationalCode)
	VALUES	(N'سعید', N'شجاعی', '111-111-111-111'),
			(N'فريد', N'تقوی', NULL),
			(N'سحر', N'زمانی', '222-222-222-222'),
			(N'علي', N'پوینده', '333-333-333-333'),
			(N'عليرضا', N'نصيري', NULL),
			(N'فاطمه', N'اكبر مقدم', '444-444-444-444'),
			(N'بهروز', N'پویان', ''),
			(N'صادق', N'نوري', ''),
			(N'مجید', N'سعادت', NULL);
GO

SELECT * FROM Person;
GO

-- .در صورتي‌كه بخواهیم كد ملي داراي مقدار يكتا باشد
CREATE UNIQUE NONCLUSTERED INDEX UNIX_NationalCode ON Person(NationalCode);
GO

CREATE UNIQUE INDEX UNIX_NationalCode ON Person(NationalCode) 
	WHERE (NationalCode <> '' AND  NationalCode IS NOT NULL);
GO

SP_HELPINDEX Person;
GO

INSERT Person(FirstName, LastName, NationalCode)
    VALUES (N'امین', N'امینی', NULL);
GO

INSERT Person(FirstName, LastName, NationalCode)
    VALUES (N'علي', N'سعادتی', '');
GO

INSERT Person(FirstName, LastName, NationalCode)
    VALUES (N'محمد', N'کشاورز', '');
GO

INSERT Person(FirstName, LastName, NationalCode)
    VALUES (N'کتایون', N'فلاحتی', '222-222-222-222');
GO

SELECT * FROM Person;
GO