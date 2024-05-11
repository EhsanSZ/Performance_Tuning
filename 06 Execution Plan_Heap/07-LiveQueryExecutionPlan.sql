
/*
Live Query Statistics استفاده از 
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
--------------------------------------------------------------------
--Live Query Statistics مشاهده 
--Properties بررسی پنجره 
SELECT  TOP 200000 
	*
FROM Customers C1 
        INNER JOIN Customers C2 
            ON C1.ID = C2.ID
GO
--مشاهده با استفاده از دستور
--اجباری استProfile استفاده از حالت 
SET STATISTICS PROFILE ON
GO
SELECT  TOP 200000 
	*
FROM Customers C1 
        INNER JOIN Customers C2 
            ON C1.ID = C2.ID
GO
SET STATISTICS PROFILE OFF
GO
SELECT * FROM sys.dm_exec_query_statistics_xml(session_id)  
SELECT * FROM sys.dm_exec_query_statistics_xml(55)  