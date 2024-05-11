
 --Execution Plan بررسی انواع 
 GO
--Estimated Execution Plan
 GO
/*
استفاده از کلید و آیکون
ها Tooltip بررسی 
*/
USE AdventureWorks2017
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
--------------------------------------------------------------------
--Actual Execution Plan
 GO
/*
استفاده از کلید و آیکون
ها Tooltip بررسی 
*/
USE AdventureWorks2017
GO
SELECT 
	SalesPersonID, YEAR(orderdate) AS OrderYear,
	COUNT(*) AS NumOrders 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 29994 
GROUP BY SalesPersonID, YEAR(OrderDate) 
HAVING COUNT(*) > 1 
ORDER BY OrderYear DESC 
GO
--------------------------------------------------------------------
--Estimated Plan , Actual Plan بررسی تفاوت 
--مثال اول
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
--ساخت جدول تستی
DROP TABLE IF EXISTS Employees 
GO
CREATE TABLE Employees
(
    ID INT IDENTITY NOT NULL,
    FirstName VARCHAR(256) DEFAULT ('Masoud'),
    LastName VARCHAR(256) DEFAULT ('Taheri'),
    CONSTRAINT PK_ID PRIMARY KEY CLUSTERED (ID)
)
GO
--ایجاد ایندکس
CREATE INDEX IX_FirstName_LastName ON Employees(FirstName, LastName)
GO
--درج تعدادی رکورد تستی
SET NOCOUNT ON
GO
INSERT Employees DEFAULT VALUES
GO 498
INSERT Employees VALUES ('AliReaza','Kamali');
GO
--مشاهده تعداد رکوردهای درج شده
SP_SPACEUSED Employees
GO

--Estimated Plan , Actual Plan مشاهده 
SELECT 
	FirstName
FROM Employees
WHERE LastName='Kamali'
GO
----------------------------------------
--مثال دوم
USE Northwind
GO
--ایجاد یک پروسیجر تستی
GO
CREATE OR ALTER PROCEDURE usp_TestPlan
(
	@P1 INT=1
)
AS
BEGIN
	IF(@P1=1) 
		SELECT TOP 10 * FROM Customers
	ELSE
		SELECT TOP 10 * FROM Products
END
GO
--Estimated Plan , Actual Plan مشاهده 
EXEC usp_TestPlan 
GO
DROP PROCEDURE IF EXISTS usp_TestPlan