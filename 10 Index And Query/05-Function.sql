
--CREATE FUNCTION Statement (Scalar)

--شكل كلي ايجاد توابع اسكالر
/*
CREATE FUNCTION name
	({@Parameter [AS] type[=default]}[,...n])
	RETURNS type
	AS
	BEGIN
		function_body
		RETURN expression
	END
*/
GO
USE Northwind
GO
--ايجاد يك فانكشن كه حرف اول نام و نام خانوادگي را استخراج مي كند
CREATE OR ALTER FUNCTION Abb (@f NVARCHAR(20)='Masoud', @l NVARCHAR(20)='Taheri')
RETURNS NCHAR(4)
AS
BEGIN
	DECLARE @X NCHAR(4)
	SET @X=LEFT(@F,1)+'.'+LEFT(@L,1)+'.'
	RETURN @X
END
GO
--Object Explorer بررسي در 
SELECT DBO.Abb ('Farid','Taheri')
SELECT DBO.Abb (default,default)
GO
SELECT EmployeeID,FirstName,LastName,dbo.abb(FirstName,LastName) AS Abb 
	FROM Employees 
GO
--------------------------------------------------------------------
/*
Function استخراج سن مشتریان با استفاده از 
*/
CREATE OR ALTER FUNCTION GetAge(@BD DATETIME)
RETURNS TINYINT
AS
BEGIN
	DECLARE @X TINYINT
	SET @X=DATEDIFF(YEAR,@BD,GETDATE()) --محاسبه اختلاف دو تاريخ بر حسب سال
	RETURN @X
END
GO
SELECT dbo.GetAge(birthdate) AS AGE,* FROM Employees 
GO
--------------------------------------------------------------------
/*
Inline Table Valued Function بررسی استفاده از 
Inline Table Valued Function = Parameterized View
*/
GO
/*
شکل کلی ایجاد تابع

CREATE FUNCTION  function_name 
    ( [ { @parameter_name [AS] scalar_parameter_data_type [ = default ] } [ ,...n ] ] ) 
RETURNS TABLE 
[ WITH < function_option > [ [,] ...n ] ] 
[ AS ] 
RETURN [ ( ] select-stmt [ ) ] 
*/
--ايجاد ويوي كه اطلاعات نام كمپاني و اطلاعات سفارش هاي مشتريان را نمايش مي دهد
CREATE OR ALTER VIEW V1
AS
SELECT C.CompanyName,O.OrderID,O.OrderDate, C.Country    
	FROM Customers C JOIN Orders O
		ON C.CustomerID=O.CustomerID 
GO
--نمايش سفارش هاي مشتريان اهل آمريكا
SELECT * FROM V1 WHERE Country=N'USA'
GO
--همين ويو با استفاده از فانكشن
--Inline Table Valued Function
CREATE OR ALTER FUNCTION FN2 (@X NVARCHAR(100))
RETURNS TABLE 
AS
RETURN
SELECT C.CompanyName,O.OrderID,O.OrderDate, C.Country    
	FROM Customers C JOIN Orders O
		ON C.CustomerID=O.CustomerID 
			WHERE C.Country=@X
GO
----------------------------------
--Normal Query
SELECT C.CompanyName,O.OrderID,O.OrderDate, C.Country    
	FROM Customers C JOIN Orders O
		ON C.CustomerID=O.CustomerID 
WHERE	
	Country=N'USA'
GO
--View
SELECT * FROM V1 WHERE Country=N'USA'
GO
--Inline Table Valued Function
SELECT * FROM FN2('USA')
GO
----------------------------------
--با جداول دیگرJoin و Inline Table Valued Function 
SELECT * FROM FN2('USA') INNER JOIN [Order Details] OD
	ON FN2.orderid=OD.OrderID 
GO
--------------------------------------------------------------------
/*
Multi Statement Table Valued Function بررسی استفاده از 
*/
GO
/*
شکل کلی ایجاد تابع

CREATE FUNCTION [owner_name.] function_name 
    ({@parameter [AS] type [= default]}[,...n ]) 
	RETURNS @return_variable TABLE < table_type_definition > 
	AS
	BEGIN 
	    function_body 
	    RETURN
	END
*/
GO
DROP FUNCTION IF EXISTS FN3
GO
CREATE OR ALTER FUNCTION FN3()
RETURNS @X TABLE (C1 INT, C2 NVARCHAR(100))
AS
BEGIN
	INSERT @X VALUES
		(1,'HELLO'),
		(2,'WORLD')
	RETURN
END
GO
SELECT * FROM FN3()
GO
--------------------------------------------------------------------
--هدف طراحي گزارشي به شكل زير مي باشد
/*
COMPANY				ORDER COUNT			NEWEST ORDER
Romero y tomillo		5			    Apr  9 1998 12:00AM
ORDER_ID			ORDER DATE			EMPLOYEE_ID
10281			   	Aug 14 1996 12:00AM		4
10282				Aug 15 1996 12:00AM		4
10306				Sep 16 1996 12:00AM		1
10917				Mar  2 1998 12:00AM		4
11013				Apr  9 1998 12:00AM		2
----------			----------			----------
*/
GO
CREATE OR ALTER FUNCTION GetSummary(@CID CHAR(5))
RETURNS @MyTab TABLE
(
Col1 VARCHAR(200),
Col2 VARCHAR(200),
Col3 VARCHAR(200)
)
AS BEGIN
	--در صورت عدم وجود ركورد از تابع خارج مي شود
	IF NOT EXISTS 
	(
		SELECT * FROM Orders
		WHERE CustomerID=@CID
	) RETURN 

	INSERT @MyTab VALUES
	('COMPANY','ORDER COUNT','NEWEST ORDER')

	DECLARE @Company VARCHAR(200)
	DECLARE @OCount INT
	DECLARE @NewOrder DATETIME

	SELECT @Company=CompanyName 
		FROM Customers
		WHERE CustomerID=@CID

	SELECT @OCount=COUNT(OrderID)
		FROM Orders
		WHERE CustomerID=@CID

	SELECT @NewOrder=MAX(OrderDate)
		FROM Orders
		WHERE CustomerID=@CID

	INSERT @MyTab VALUES
	(@Company,@OCount,@NewOrder)

	INSERT @MyTab VALUES
	('ORDER_ID','ORDER DATE','EMPLOYEE_ID')

	INSERT @MyTab 
	SELECT OrderID, OrderDate, EmployeeID
		FROM Orders WHERE CustomerID=@CID

	INSERT @MyTab VALUES
	('----------','----------','----------')

	RETURN 
END
GO
SELECT * FROM DBO.GetSummary('VINET')
UNION ALL
SELECT * FROM DBO.GetSummary('ALFKI')
GO
--------------------------------------------------------------------
--مي باشد با اين تفاوت كه يك طرف جدول و يك طرف تابع جدولي قرار مي گيرد CROSS JOIN همانند CROSS APPLY
SELECT c.CompanyName,tmp.* FROM Customers c CROSS APPLY GetSummary(c.CustomerID ) tmp
	WHERE c.Country='spain'

SELECT c.CompanyName,tmp.* FROM Customers c OUTER APPLY GetSummary(c.CustomerID ) tmp
	WHERE c.Country='spain' --مشتري كه سفارش نداشته مي آورد

SELECT * FROM Customers
	WHERE Country='spain'
--------------------------------------------------------------------
/*
نکات پرفورمنسی در خصوص استفاده از تابع
*/
--Show Actual Execution Plan 
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
USE AdventureWorks2017
GO
--SUBSTRING vs. LIKE
SELECT d.Name FROM HumanResources.Department AS d
	WHERE SUBSTRING(d.[Name], 1, 1) = 'F' 
GO
SELECT d.Name FROM HumanResources.Department AS d
	WHERE d.[Name] LIKE 'F%' ;
GO
--Date Part Comparison
--بررسی جهت وجود ایندکس+ حذف ایندکس
IF	EXISTS
	(
		 SELECT object_id FROM sys.indexes
			 WHERE object_id = OBJECT_ID(N'Sales.SalesOrderHeader')
				AND name = N'IndexTest'
	)
		DROP INDEX IndexTest ON [Sales].[SalesOrderHeader]
GO
--ایجاد ایندکس
CREATE INDEX IndexTest ON Sales.SalesOrderHeader(OrderDate)
GO
--Estimate Number , Actual Number مقایسه 
SELECT 
	soh.SalesOrderID,
	soh.OrderDate
FROM  Sales.SalesOrderHeader AS soh
JOIN  Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
		WHERE  DATEPART(yy, soh.OrderDate) = 2012
			AND DATEPART(mm, soh.OrderDate) = 4
GO
SELECT 
	soh.SalesOrderID,
	soh.OrderDate
FROM  Sales.SalesOrderHeader AS soh
JOIN  Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
		WHERE  soh.OrderDate >= '2012-04-01'
			AND soh.OrderDate < '2012-05-01'
GO
--------------------------------------------------------------------
USE tempdb
GO
DROP TABLE IF EXISTS lds;
GO
CREATE TABLE lds
(
	lds_id INT NOT NULL, 
	lds_txt char(36) NOT NULL
);
GO
--درج دیتا تستی در جدول
WITH 
L1 AS (SELECT n = 1 UNION ALL SELECT 1),		--2 rows
L2 AS (SELECT n = 1 FROM L1 a CROSS JOIN L1 b),	--4 rows
L3 AS (SELECT n = 1 FROM L2 a CROSS JOIN L2 b),	--16 rows
L4 AS (SELECT n = 1 FROM L3 a CROSS JOIN L3 b),	-- 256 rows
L5 AS (SELECT n = 1 FROM L4 a CROSS JOIN L4 b),	-- 65K rows
ITally AS 
(	SELECT n = ROW_NUMBER() OVER (ORDER BY (SELECT 1))
	FROM L5 a CROSS JOIN L5 b)					-- 4billion+ rows
INSERT dbo.lds
SELECT TOP (1000000) 
	ROW_NUMBER() OVER (ORDER BY (SELECT 1)), newid()
FROM ITally ;
GO
--مشاهده تعداد رکوردهای درج شده در جدول
SP_SPACEUSED lds
GO
--به جدول PK اضافه کردن 
ALTER TABLE lds
	ADD CONSTRAINT pk_lds_x PRIMARY KEY(lds_id);
GO
--Multi Statment ایجاد فانکشن از نوع
IF OBJECT_ID('tempdb.dbo.mTVF_CheckString') IS NOT NULL 
	DROP FUNCTION dbo.mTVF_CheckString;
GO
CREATE FUNCTION dbo.mTVF_CheckString(@pattern varchar(5))
RETURNS @x TABLE 
(
	lds_id int not null,
	lds_txt	varchar(36) not null,
	pattern_txt varchar(5) null,	-- user can pass the function a null value
	has_pattern bit
)
AS
BEGIN
  INSERT @x
	SELECT 
		lds_id,
		lds_txt,
		@pattern,
		CASE WHEN charindex(@pattern, lds_txt) = 0 THEN 0 ELSE 1 END
	FROM dbo.lds;
	RETURN;
END
GO
--Inline ایجاد فانکشن از نوع
IF OBJECT_ID('tempdb.dbo.iTVF_CheckString') IS NOT NULL 
	DROP FUNCTION dbo.iTVF_CheckString;
GO
CREATE FUNCTION dbo.iTVF_CheckString(@pattern varchar(5))
RETURNS TABLE
AS 
RETURN
	SELECT 
		lds_id,
		lds_txt,
		@pattern AS pattern_txt,
		CASE WHEN charindex(@pattern, lds_txt) = 0 THEN 0 ELSE 1 END AS has_pattern
	FROM dbo.lds;
GO


---------------------------
--Inline,Multi Statement Function مقایسه 
DECLARE @pattern varchar(5) = '123-a';

SET STATISTICS TIME ON
SET STATISTICS IO ON


	PRINT char(10)+'Inline TVF:';
	SELECT * 
	FROM dbo.iTVF_CheckString(@pattern)
	WHERE has_pattern = 1;

	PRINT char(10)+'Multi-line TVF:' +char(32);
	SELECT * 
	FROM dbo.mTVF_CheckString(@pattern)
	WHERE has_pattern = 1;

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO
--------------------------------------------------------------------
