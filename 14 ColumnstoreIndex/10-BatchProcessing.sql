
/*
بکاپ ریستور شود تا کار سریع تر جلو رود
اسکریپت های پس از درج ایجاد شود
*/
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
RESTORE FILELISTONLY FROM DISK ='C:\Temp\MyDB2017_BatchProcess.bak'
GO
RESTORE DATABASE MyDB2017 FROM DISK ='C:\Temp\MyDB2017_BatchProcess.bak' WITH 
	MOVE 'MyDB2017' TO 'C:\Temp\MyDB2017.mdf',
	MOVE 'MyDB2017_log' TO 'C:\Temp\MyDB2017_log.ldf',
	STATS=1
GO
USE MyDB2017
GO
--------------------------------------------------------------------
USE master
GO
--ساخت بانک اطلاعاتی
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
DROP TABLE IF EXISTS dbo.DimBranches
DROP TABLE IF EXISTS dbo.DimArticles
DROP TABLE IF EXISTS dbo.DimDates
DROP TABLE IF EXISTS dbo.FactSales
GO
--ایجاد جدول
CREATE TABLE dbo.DimBranches
(
	BranchId int not null primary key,
	BranchNumber nvarchar(32) not null,
	BranchCity nvarchar(32) not null,
	BranchRegion nvarchar(32) not null,
	BranchCountry nvarchar(32) not null
)
GO
CREATE TABLE dbo.DimArticles
(
	ArticleId int not null primary key,
	ArticleCode nvarchar(32) not null,
	ArticleCategory nvarchar(32) not null
)
GO
CREATE TABLE dbo.DimDates
(
	DateId int not null primary key,
	ADate date not null,
	ADay tinyint not null,
	AMonth tinyint not null,
	AnYear smallint not null,
	AQuarter tinyint not null,
	ADayOfWeek tinyint not null
)
GO
--------------------------------
/*
ساخت جدول به کلید کلاستر ایندکس توجه کنید
Data_Compression=Page
*/
CREATE TABLE dbo.FactSales
(
	DateId int not null
	foreign key references dbo.DimDates(DateId),
	ArticleId int not null
	foreign key references dbo.DimArticles(ArticleId),
	BranchId int not null
	foreign key references dbo.DimBranches(BranchId),
	OrderId int not null,
	Quantity decimal(9,3) not null,
	UnitPrice money not null,
	Amount money not null,
	DiscountPcnt decimal (6,3) not null,
	DiscountAmt money not null,
	TaxAmt money not null,
	CONSTRAINT PK_FactSales PRIMARY KEY (DateId, ArticleId, BranchId, OrderId)
	WITH (DATA_COMPRESSION = PAGE)
)
GO
--------------------------------
--درج دیتای تستی در جدول
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N4 AS T2) -- 1,024 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
,Dates(DateId, ADate)
AS
(
	SELECT ID, DATEADD(DAY,ID,'2014-12-31')
	FROM IDs
	WHERE ID <= 727
)
INSERT INTO dbo.DimDates(DateId, ADate, ADay, AMonth, AnYear, AQuarter, ADayOfWeek)
	SELECT 
		DateID, ADate, Day(ADate), Month(ADate),
		Year(ADate), datepart(qq,ADate),datepart(dw,ADate)
	FROM Dates
GO
--------------------------------
--درج دیتای تستی در جدول
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N3)
INSERT INTO dbo.DimBranches(BranchId, BranchNumber, BranchCity, BranchRegion, BranchCountry)
	SELECT 
		ID,CONVERT(NVARCHAR(32),ID), 'City', 
		'Region', 'Country'
	FROM IDs WHERE ID <= 13
GO
--------------------------------
--درج دیتای تستی در جدول
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N2 AS T2) -- 1,024 ROWS
,IDs(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT INTO dbo.DimArticles(ArticleId, ArticleCode, ArticleCategory)
	SELECT 
		ID, CONVERT(NVARCHAR(32),ID),
		'Category ' + CONVERT(NVARCHAR(32),ID % 51)
	FROM IDs
	WHERE ID <= 1021
GO
--------------------------------
--درج دیتای تستی در جدول
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,N6(C) AS (SELECT 0 FROM N5 AS T1 CROSS JOIN N4 AS T2) -- 16,777,216 ROWS
,IDs(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N6)
INSERT INTO dbo.FactSales
	(
		DateId, ArticleId, BranchId, OrderId, 
		Quantity, UnitPrice, Amount,
		DiscountPcnt, DiscountAmt, TaxAmt
	)
SELECT 
	ID % 727 + 1, ID % 1021 + 1, 
	ID % 13 + 1, ID, ID % 51 + 1, 
	ID % 25 + 0.99,(ID % 51 + 1) * (ID % 25 + 0.99),
	0, 0, (ID % 25 + 0.99) * (ID % 10) * 0.01
FROM IDs
GO
--------------------------------
--بررسی داده ها ی وجود در جداول و حجم مربوط به آنها\
--بررسی حجم داده ها
EXEC SP_SPACEUSED DimBranches
EXEC SP_SPACEUSED DimArticles
EXEC SP_SPACEUSED DimDates
EXEC SP_SPACEUSED FactSales
GO
--بررسی ایندکس های جدول
EXEC SP_HELPINDEX DimBranches
EXEC SP_HELPINDEX DimArticles
EXEC SP_HELPINDEX DimDates
EXEC SP_HELPINDEX FactSales
GO
--بررسی نمونه ای از داده ها
SELECT TOP 2 * FROM DimBranches
SELECT TOP 2 * FROM DimArticles
SELECT TOP 2 * FROM DimDates
SELECT TOP 2 * FROM FactSales
GO
--------------------------------
--NonClustered Columnstore Index ساخت
CREATE NONCLUSTERED COLUMNSTORE INDEX IDX_FactSales_ColumnStore ON dbo.FactSales
	(
		DateId, ArticleId, BranchId, 
		Quantity, UnitPrice, Amount
	)
GO
--------------------------------
USE MyDB2017
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
/*
Show Execution Plan
Show Actual Execution Plan Mode
Show IO,Time Statistics
*/
GO
/*
Clustered Index اجبار به استفاده از 
و اجرای کوئری به صورت سریال
*/
SELECT 
	a.ArticleCode, SUM(s.Amount) AS [TotalAmount]
FROM dbo.FactSales s WITH (INDEX = 1) 
INNER JOIN dbo.DimArticles a 
	ON s.ArticleId = a.ArticleId
GROUP BY 
	a.ArticleCode
OPTION (MAXDOP 1)
GO
/*
Columnstore Index استفاده از 
و اجبار به اجرای کوئری به صورت سریال
*/
SELECT 
	a.ArticleCode, SUM(s.Amount) AS [TotalAmount]
FROM dbo.FactSales s 
INNER JOIN dbo.DimArticles a 
	ON s.ArticleId = a.ArticleId
GROUP BY 
	a.ArticleCode
OPTION (MAXDOP 1)
GO
/*
Clustered Index اجبار به استفاده از 
و اجرای کوئری به صورت پارالل
*/
SELECT 
	a.ArticleCode, SUM(s.Amount) AS [TotalAmount]
FROM dbo.FactSales s WITH (INDEX = 1) 
INNER JOIN dbo.DimArticles a 
	ON s.ArticleId = a.ArticleId
GROUP BY 
	a.ArticleCode
GO
/*
Columnstore Index استفاده از 
و اجرای کوئری به صورت پارالل
*/
SELECT 
	a.ArticleCode, SUM(s.Amount) AS [TotalAmount]
FROM dbo.FactSales s 
INNER JOIN dbo.DimArticles a 
	ON s.ArticleId = a.ArticleId
GROUP BY 
	a.ArticleCode
GO
/*
IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX بررسی آپشن
Columnstore Index عدم استفاده از
*/
SELECT 
	a.ArticleCode, SUM(s.Amount) AS [TotalAmount]
FROM dbo.FactSales s 
INNER JOIN dbo.DimArticles a 
	ON s.ArticleId = a.ArticleId
GROUP BY 
	a.ArticleCode
OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
GO
--------------------------------------------------------------------
/*
به بعد SQL Server 2016 توجه داشته باشید که از 
دارند  Batch Process بیشتر اپراتورها حالت 
*/
GO