
/*
خودكارStatistcs پيش نيازهاي به روز رساني و ايجاد 
*/
-- به صورت خودکارStatistics ایجاد   
ALTER DATABASE Northwind 
	SET AUTO_CREATE_STATISTICS ON WITH NO_WAIT
GO
--Statistics به روزرسانی   
ALTER DATABASE Northwind
	SET AUTO_UPDATE_STATISTICS ON  WITH NO_WAIT
GO
-- به شكل آسنكرونStatistics فعال سازي به روز رساني خودكار 
ALTER DATABASE Northwind
	SET AUTO_UPDATE_STATISTICS_ASYNC ON  WITH NO_WAIT
GO
--------------------------------------------------------------------
USE Northwind
GO
ALTER DATABASE Northwind
	SET AUTO_UPDATE_STATISTICS_ASYNC OFF  WITH NO_WAIT
GO
/*
در این حالت اجرای کوئری منوط به بروز شدن آمار نمی باشد
کو ئری با همان پلن قبلی اجرا می شود و در پشت صحنه استت به روز می شود
می گویند SubOptimal Plan به پلن قبلی اصظلاحا 
*/
--تنظیم به روزرسانی خودکار به ازای جداول
EXEC sp_autostats 'Customers'
--EXEC sp_autostats 'Customers','OFF'
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('Customers2')>0
       DROP TABLE Customers2
GO
--تهیه کپی از جدول
SELECT * INTO Customers2 FROM Customers
GO
--ایجاد ایندکس
CREATE INDEX IX_Country ON Customers2(Country)
GO
--های یک جدولStats استخراج لیست
SP_HELPSTATS N'Customers2', 'ALL' 
GO
DBCC SHOW_STATISTICS ('Customers2','IX_Country') WITH HISTOGRAM
GO
INSERT INTO Customers2(CustomerID,CompanyName,ContactTitle,City,Country) 
	VALUES('M_T','NikAmooz','Owner','Tehran','IRAN')
GO 499
--Stats بررسی به روز بودن
--Iran ردیف
DBCC SHOW_STATISTICS ('Customers2','IX_Country') WITH HISTOGRAM
GO
SET STATISTICS IO ON
GO
--Estimate Row Number مشاهده
--Actual Plan & Check IO
SELECT * FROM Customers2	
	WHERE Country='IRAN'
GO
--می کند Stats اقدام به به روزرسانی Query Optimizerآیا 
DBCC SHOW_STATISTICS ('Customers2','IX_Country') WITH HISTOGRAM
GO
INSERT INTO Customers2(CustomerID,CompanyName,ContactTitle,City,Country) 
	VALUES('M_T','DSICT','Owner','Tehran','IRAN')
GO
DBCC SHOW_STATISTICS ('Customers2','IX_Country') WITH HISTOGRAM
GO
--Estimate Row Number مشاهده
--Actual Plan & Check IO
SELECT * FROM Customers2	
	WHERE Country='IRAN'
GO
DBCC SHOW_STATISTICS ('Customers2','IX_Country') WITH HISTOGRAM
GO
SET STATISTICS IO OFF
GO
------------------------------------------------------------------------------------------
USE Northwind
GO
--Stats ایجاد اسکریپت برای به روزرسانی
--بررسی جهت وجود جدول
IF OBJECT_ID('Customers2')>0
       DROP TABLE Customers2
GO
--تهیه کپی از جدول
SELECT * INTO Customers2 FROM Customers
GO
--ایجاد ایندکس
CREATE INDEX IX_Country ON Customers2(Country)
GO
INSERT INTO Customers2(CustomerID,CompanyName,ContactTitle,City,Country) 
	VALUES('M_T','DSICT','Owner','Tehran','IRAN')
GO 499

--Stats بررسی وضعیت تغییرات
SELECT DISTINCT
    OBJECT_NAME(SI.object_id) as Table_Name
    ,SI.[name] AS Statistics_Name
    ,STATS_DATE(SI.object_id, SI.index_id) AS Last_Stat_Update_Date
    ,SSI.rowmodctr AS RowModCTR
    ,SP.rows AS Total_Rows_In_Table
    ,'UPDATE STATISTICS ['+SCHEMA_NAME(SO.schema_id)+'].[' 
        + object_name(SI.object_id) + ']' 
            + SPACE(2) + SI.[name] AS Update_Stats_Script
FROM 
    sys.indexes AS SI (nolock) 
JOIN sys.objects AS SO (nolock) 
	ON SI.object_id=SO.object_id
JOIN sys.sysindexes SSI (nolock)
	ON SI.object_id=SSI.id
		AND SI.index_id=SSI.indid 
JOIN sys.partitions AS SP
	ON SI.object_id=SP.object_id
WHERE SSI.rowmodctr>0
	AND STATS_DATE(SI.object_id, SI.index_id) IS NOT NULL
	AND SO.type='U'
ORDER BY SSI.rowmodctr DESC
GO
-----
--مر بوط به كليه جداولSTATISTICS به روز رساني 
EXEC sp_updatestats
GO
------------------------------------------------------------------------------------------
--Statistics and Execution Plans
USE tempdb
GO
IF OBJECT_ID('Books')>0
	DROP TABLE Books
GO
CREATE TABLE dbo.Books
(
	BookId int identity(1,1) not null,
	Title nvarchar(256) not null,
	ISBN char(14) not null, 
	Placeholder char(150) null
);
GO
CREATE UNIQUE CLUSTERED INDEX IDX_Books_BookId on dbo.Books(BookId);
GO
-- 1,252,000 rows
;WITH Prefix(Prefix)
AS
(
	SELECT 100 
	UNION all
	SELECT Prefix + 1
	FROM Prefix
	WHERE Prefix < 600
)
,Postfix(Postfix)
AS
(
	SELECT 100000001
	UNION all
	SELECT Postfix + 1
	FROM Postfix
	WHERE Postfix < 100002500
)
INSERT INTO dbo.Books(ISBN, Title)
	SELECT 
		CONVERT(char(3), Prefix) + '-0' + CONVERT(CHAR(9),Postfix)
		,'Title for ISBN' + CONVERT(CHAR(3), Prefix) + '-0' + CONVERT(CHAR(9),Postfix)
	FROM Prefix cross join Postfix
OPTION (maxrecursion 0);
GO
CREATE NONCLUSTERED INDEX IDX_Books_ISBN on dbo.Books(ISBN);
GO
--250,000 rows
;WITH Postfix(Postfix)
AS
(
	SELECT 100000001
	UNION ALL
	SELECT Postfix + 1
	FROM Postfix
	WHERE Postfix < 100250000
)
INSERT INTO dbo.Books(ISBN, Title)
SELECT
'999-0' + CONVERT(CHAR(9),Postfix)
,'Title for ISBN 999-0' + CONVERT(CHAR(9),Postfix)
FROM Postfix
OPTION (maxrecursion 0)
GO
-- Enable "Include Actual Execution Plan"
-- Check estimated # of rows vs. actual
SET STATISTICS IO ON
SELECT * FROM dbo.Books WHERE ISBN LIKE '999%' --  250,000 rows روش جدبد
SELECT * FROM dbo.Books WHERE ISBN LIKE '999%' OPTION(QUERYTRACEON 9481) -- 250,000 rows روش قدیمی
SET STATISTICS IO OFF
GO
--بررسی شود آیا رکوردی با 999 دیده می شود
DBCC SHOW_STATISTICS('dbo.Books',IDX_BOOKS_ISBN) 
GO
--هاStats بررسی وضعیت تغییرات
--های به روز نشدهStatistics نمایش 
SELECT DISTINCT
    OBJECT_NAME(SI.object_id) as Table_Name
    ,SI.[name] AS Statistics_Name
    ,STATS_DATE(SI.object_id, SI.index_id) AS Last_Stat_Update_Date
    ,SSI.rowmodctr AS RowModCTR
    ,SP.rows AS Total_Rows_In_Table
    ,'UPDATE STATISTICS ['+SCHEMA_NAME(SO.schema_id)+'].[' 
        + object_name(SI.object_id) + ']' 
            + SPACE(2) + SI.[name] AS Update_Stats_Script
FROM 
    sys.indexes AS SI (nolock) 
JOIN sys.objects AS SO (nolock) 
	ON SI.object_id=SO.object_id
JOIN sys.sysindexes SSI (nolock)
	ON SI.object_id=SSI.id
		AND SI.index_id=SSI.indid 
JOIN sys.partitions AS SP
	ON SI.object_id=SP.object_id
WHERE SSI.rowmodctr>0
	AND STATS_DATE(SI.object_id, SI.index_id) IS NOT NULL
	AND SO.type='U'
ORDER BY SSI.rowmodctr DESC
GO
--Statistics به روز رسانی
UPDATE STATISTICS dbo.Books IDX_Books_ISBN WITH FULLSCAN;
GO
--بررسی شود آیا رکوردی با 999 دیده می شود
DBCC SHOW_STATISTICS('dbo.Books',IDX_BOOKS_ISBN) 
GO
SET STATISTICS IO ON
SELECT * FROM dbo.Books WHERE ISBN LIKE '999%' --  250,000 rows روش جدبد
SELECT * FROM dbo.Books WHERE ISBN LIKE '999%' OPTION(QUERYTRACEON 9481) -- 250,000 rows روش قدیمی
SET STATISTICS IO OFF
GO
