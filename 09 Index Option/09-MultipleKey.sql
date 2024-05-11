
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
--------------------------------------------------------------------
--ساخت جدول تستی
DROP TABLE IF EXISTS TestingIndexUsage 
GO
CREATE TABLE TestingIndexUsage 
(
	ID INT IDENTITY PRIMARY KEY,
	FilterColumn1 INT,
	FilterColumn2 INT,
	FilterColumn3 INT,
	Filler CHAR(500) DEFAULT 'NikAmooz'
)
GO
--درج تعدادی رکورد تستی
INSERT INTO TestingIndexUsage (FilterColumn1, FilterColumn2, FilterColumn3)
	SELECT TOP ( 1000000 )
		ABS(CHECKSUM(NEWID()))%200,
		ABS(CHECKSUM(NEWID()))%40,
		ABS(CHECKSUM(NEWID()))%20
	FROM msdb.sys.columns a 
	CROSS JOIN msdb.sys.columns b
GO
--مشاهده رکوردهای موجود در جدول
SELECT * FROM TestingIndexUsage
GO
--------------------------------------------------------------------
--ایجاد ایندکس
CREATE INDEX idx_Temp_FilterColumn1 ON dbo.TestingIndexUsage (FilterColumn1)
CREATE INDEX idx_Temp_FilterColumn2 ON dbo.TestingIndexUsage (FilterColumn2)
CREATE INDEX idx_Temp_FilterColumn3 ON dbo.TestingIndexUsage (FilterColumn3)
GO
--جستجوی رکورد
SELECT 
	ID --,Filler
FROM dbo.TestingIndexUsage
WHERE 
	FilterColumn1 = 68 -- 4993 matching rows
	AND FilterColumn2 = 26 -- 24818 matching rows
	AND FilterColumn3 = 3  -- 49915 matching rows
GO
--حذف ایندکس های قبلی
DROP INDEX idx_Temp_FilterColumn1 ON dbo.TestingIndexUsage
DROP INDEX idx_Temp_FilterColumn2 ON dbo.TestingIndexUsage
DROP INDEX idx_Temp_FilterColumn3 ON dbo.TestingIndexUsage
GO
CREATE INDEX idx_Temp_FilterColumn123 ON dbo.TestingIndexUsage 
	(FilterColumn1, FilterColumn2, FilterColumn3)
GO
--جستجوی رکورد
SELECT 
	ID --,Filler
FROM dbo.TestingIndexUsage
WHERE 
	FilterColumn1 = 68 -- 4993 matching rows
	AND FilterColumn2 = 26 -- 24818 matching rows
	AND FilterColumn3 = 3  -- 49915 matching rows
GO
SELECT 
	ID --,Filler
FROM dbo.TestingIndexUsage
WHERE 
	 FilterColumn2 = 26 -- 24818 matching rows
	AND FilterColumn3 = 3  -- 49915 matching rows
GO
