
/*
Execution Plan مقایسه 
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
--بررسی رکوردهای درج شده
SP_SPACEUSED Customers
GO
SELECT TOP 1000 * FROM Customers
GO
--ایجاد یک ایندکس تستی 
CREATE INDEX IX_PhoneNumber ON Customers(PhoneNumber)
GO
--------------------------------------------------------------------
--In Place مقایسه به صورت 

--کوئری اول
SELECT 
	*
FROM Customers WITH(INDEX(0))
WHERE PhoneNumber = '99750000'
GO
--کوئری دوم
SELECT 
	*
FROM Customers 
WHERE PhoneNumber = '99750000'
GO
--------------------------------------------------------------------
--Compare ShowPlan استفاده از 
SELECT 
	*
FROM Customers WITH(INDEX(0))
WHERE PhoneNumber = '99750000'
GO
--کوئری دوم
SELECT 
	*
FROM Customers 
WHERE PhoneNumber = '99750000'
GO
--------------------------------------------------------------------
/*
کردن دیتابیس دوم برای مقایسه شرح داده شود RESTORE داستان 
*/