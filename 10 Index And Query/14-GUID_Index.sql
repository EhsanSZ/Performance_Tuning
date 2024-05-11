
USE tempdb
GO
--NEWID آشنایی با تابع
SELECT NEWID()
GO
--UNIQUEIDENTIFIER بررسی دیتا تایپ
DECLARE @X UNIQUEIDENTIFIER
SET @X= NEWID()
SELECT @X AS 'Sample GUID'
SELECT DATALENGTH(@X) AS 'Data Length'
SELECT LEN('5A31D0CF-E62A-44D2-B930-DB6ED79E33EE')
GO

USE tempdb
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('Employees1')>0
	DROP TABLE Employees1
GO
--ایجاد جدول
CREATE TABLE Employees1
(
	ID UNIQUEIDENTIFIER PRIMARY KEY,
	EmpID INT UNIQUE,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
--بررسی ایندکس های موجود به ازای جدول
SP_HELPINDEX Employees1
GO
--بررسی تعداد رکوردهای جدول
SP_SPACEUSED Employees1
GO
--ایندکس های موجود در جدولFragmentation بررسی وضعیت 
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Employees1'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
--درج رکورد تستی در جدول
DECLARE @C INT=1
DECLARE @FirstName NVARCHAR(100)
DECLARE @LastName NVARCHAR(100)
WHILE @C<=10000
BEGIN
	SET @FirstName='F'+CAST(@C AS NVARCHAR(10))
	SET @LastName='F'+CAST(@C AS NVARCHAR(10))
	INSERT INTO Employees1 VALUES (NEWID(),@C,@FirstName,@LastName)
	SET @C+=1
END
GO
--بررسی تعداد رکوردهای جدول
SP_SPACEUSED Employees1
GO
--ایندکس های موجود در جدولFragmentation بررسی وضعیت 
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Employees1'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
--IO بررسی میزان 
SET STATISTICS IO ON
GO
SELECT * FROM Employees1 
GO
SET STATISTICS IO OFF
--------------------------------------------------------------------
----------------------------
--راه حل رفع مشکل
----------------------------
USE tempdb
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('Employees2')>0
	DROP TABLE Employees2
GO

--ایجاد جدول
CREATE TABLE Employees2
(
	ID UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID()  PRIMARY KEY,
	EmpID INT UNIQUE,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
--بررسی ایندکس های موجود به ازای جدول
SP_HELPINDEX Employees2
GO
--بررسی تعداد رکوردهای جدول
SP_SPACEUSED Employees2
GO
--ایندکس های موجود در جدولFragmentation بررسی وضعیت 
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Employees2'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
--درج رکورد تستی در جدول
DECLARE @C INT=1
DECLARE @FirstName NVARCHAR(100)
DECLARE @LastName NVARCHAR(100)
WHILE @C<=10000
BEGIN
	SET @FirstName='F'+CAST(@C AS NVARCHAR(10))
	SET @LastName='F'+CAST(@C AS NVARCHAR(10))
	INSERT INTO Employees2(EmpID,FirstName,LastName) VALUES (@C,@FirstName,@LastName)
	SET @C+=1
END
GO
--بررسی تعداد رکوردهای جدول
SP_SPACEUSED Employees2
GO
--ایندکس های موجود در جدولFragmentation بررسی وضعیت 
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Employees2'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
--------------------------------------------------------------------
--این موضوع جلوتر بررسی خواهد شد**CheckSum کاهش حجم ایندکس با 