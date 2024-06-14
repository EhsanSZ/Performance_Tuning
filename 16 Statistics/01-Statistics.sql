
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO
---------------------------------
USE MyDB2017
GO
--بررسی جهت وجود جدول و حذف آن
DROP TABLE IF EXISTS Person_Contact
GO
CREATE TABLE Person_Contact
(
	ID INT IDENTITY PRIMARY KEY	,
	FirstName NVARCHAR(60),
	LastName NVARCHAR(60),
	Phone NVARCHAR(15),
	Title NVARCHAR(15)
)
GO
--درج تعدادی رکورد در جدول
INSERT INTO Person_Contact (FirstName,LastName,Phone,Title) VALUES
	(N'John',N'Smith',N'425-555-1234',N'Mr'),
	(N'Erik',N'Andersen',N'425-555-1111',N'Mr'),
	(N'Erik',N'Andersen',N'425-555-3333',N'Mr'),
	(N'Jeff',N'Williams',N'425-555-0000',N'Dr'),
	(N'Larry',N'Zhang',N'425-555-2222',N'Mr')
GO
SELECT * FROM Person_Contact
GO
/*
Show Actual Execution Plan
Estimated Number of Rows
Actual Number of Rows
*/
SELECT * FROM Person_Contact WHERE LastName='Andersen'
GO
--های یک جدولStats استخراج لیست
SP_HELPSTATS N'Person_Contact', 'ALL' --ALL lists statistics for all indexes and also columns that have statistics 
GO
SP_HELPSTATS N'Person_Contact', 'Stats'--STATS only lists statistics not associated with an index
GO
--استفاده از ویو
SELECT 
	OBJECT_NAME(object_id) ,* 
FROM SYS.stats
GO
SELECT 
	OBJECT_NAME(object_id) ,* 
FROM SYS.stats
WHERE object_id=OBJECT_ID('Person_Contact')
GO
--------------------------------------------------------------------
/*
Execution Plan در CARDINALITY ESTIMATION بررسی
CardinalityEstimationModelVersion 
*/
USE MyDB2017
GO
SELECT * FROM Person_Contact WHERE LastName='Andersen'
GO
/*
در مد قدیمی CARDINALITY ESTIMATION بررسی
Always on حالت 
*/
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = off
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY 
	SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY 
	SET LEGACY_CARDINALITY_ESTIMATION = On
GO
/*
To use the LegacyCE when the database is set to the new CE, use Trace Flag 9481.
To use the New CE when the database is set to the LegacyCE, use Trace Flag 2312.
*/
--New CE
SELECT * FROM Person_Contact WHERE LastName='Andersen'
	OPTION (QUERYTRACEON 2312)
GO
--LegacyCE
SELECT * FROM Person_Contact WHERE LastName='Andersen'
	OPTION (QUERYTRACEON 9481)
