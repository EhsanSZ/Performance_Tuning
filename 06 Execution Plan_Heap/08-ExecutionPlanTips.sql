
/*
Execution Plan نکات مهم مربوط به 
*/
--ایجاد بانک اطلاعاتی تستی
USE master
GO
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
--ایجاد یک جدول تستی و درج دیتا نسبتا زیاد در آن
DROP TABLE IF EXISTS Customers
GO
CREATE TABLE Customers
( 
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FullName NVARCHAR(50),  
	PhoneNumber NVARCHAR(20),
    CreationDate DATETIME, 
	ChangeDate DATETIME
)
GO
INSERT INTO Customers(FullName, PhoneNumber, CreationDate, ChangeDate)
SELECT TOP 500000 
	NEWID(),100000000 - ROW_NUMBER() OVER (ORDER BY SC1.object_id),
	GETDATE(), GETDATE()
FROM SYS.all_columns SC1
        CROSS JOIN SYS.all_columns SC2
GO
--------------------------------------------------------------------
/*
بررسی و شرح مربوط به مسائل هزینه
بررسی و شرح خطوط مربوط به انتقال داده 
*/
SELECT  TOP 200000 
	*
FROM Customers C1 
INNER JOIN Customers C2 ON C1.ID = C2.ID
GO
--------------------------------------------------------------------
/*
Estimate Number of Rows , Actual Number of Rows بررسی 
*/
SELECT 
	*
FROM Customers 
WHERE PhoneNumber = '99750000'
GO
--------------------------------------------------------------------
/*
Warning بررسی داستان مربوط به 
*/
SELECT  TOP 200000 
	*
FROM Customers C1 
INNER JOIN Customers C2 ON C1.ID = C2.ID
WHERE 
	C1.PhoneNumber=99999998
GO
--------------------------------------------------------------------
/*
یا جستجوی اضافی Residual Predicate بررسی 
Residual = باقی مانده
*/
USE MyDB2017
GO
DROP TABLE IF EXISTS SeekPredicateExample
GO
CREATE TABLE SeekPredicateExample 
(
	DT DATETIME NOT NULL,
	Some_Data CHAR(1000) NULL
)
GO
INSERT INTO SeekPredicateExample (DT)
	SELECT TOP (100000)
	DATEADD(SECOND, CAST(FLOOR(RAND(CHECKSUM(NEWID())) * 3600 * 24 * 10) AS INT), '20180101')
FROM sys.all_columns AS t1
CROSS JOIN sys.all_columns AS t2
GO
CREATE CLUSTERED INDEX IX_CL_SeekPredicateExample ON SeekPredicateExample (DT)
GO
SP_SPACEUSED SeekPredicateExample
GO
SELECT * FROM SeekPredicateExample
GO
--کوئری اول 
/*
Show Actual Execution Plan
Predicate (جستجوی دوم) , SeekPredicate (جستجوی اول)
*/
DECLARE @From_V1 DATETIME = '20180101'
DECLARE	@From_V2 DATETIME = '20180105'
DECLARE @To_V3   DATETIME = '20180108'
 
SELECT 
	COUNT(*)
FROM SeekPredicateExample AS t
WHERE
	t.DT >= @From_V1
	AND t.DT >= @From_V2
	AND t.DT < @To_V3
GO
---------------------------------
--کوئری دوم : بازنویسی شده کوئری اول
DECLARE @From_V1 DATETIME = '20180101'
DECLARE	@From_V2 DATETIME = '20180105'
DECLARE @To_V3   DATETIME = '20180108'
 
IF @From_V2 > @From_V1
	SET @From_V1 = @From_V2

SELECT 
	COUNT(*)
FROM SeekPredicateExample AS t
WHERE
	t.DT >= @From_V1
	AND t.DT < @To_V3
