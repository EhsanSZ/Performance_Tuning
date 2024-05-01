
--برای تنظیم اندازه لاگ فایل Best Practice بررسی یک 
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
--ایجاد جدول تستی
CREATE TABLE Employees
(
    ID INT IDENTITY NOT NULL PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
)
GO
CREATE PROCEDURE Insert_Employees1
AS
BEGIN
SET NOCOUNT ON
 
	DECLARE @counter AS INT = 0
	DECLARE @start datetime
	Select @start = getdate()
 
    WHILE (@counter < 10000)
        BEGIN
			BEGIN TRAN
             INSERT INTO Employees(FullName,DateAdded) VALUES( 'www.Ehsansz.com',GETDATE())
             SET @counter = @counter + 1
            COMMIT WITH (DELAYED_DURABILITY = OFF)
         END
	SELECT DATEDIFF(SECOND, @START, GETDATE() )
END
GO
--RUN 06-ProcessMonitor and Filter LDF File
EXEC Insert_Employees1
GO
--پاک کردن محتوای جدول
TRUNCATE TABLE Employees
GO
--------------------------------------------------------
--DELAYED_DURABILITY فعال سازی  
ALTER DATABASE MyDB2017 SET DELAYED_DURABILITY = ALLOWED --FORCED
GO
CREATE PROCEDURE Insert_Employees2
AS
BEGIN
SET NOCOUNT ON
 
	DECLARE @counter AS INT = 0
	DECLARE @start datetime
	Select @start = getdate()
 
    WHILE (@counter < 10000)
        BEGIN
			BEGIN TRAN
             INSERT INTO Employees(FullName,DateAdded) VALUES( 'www.Ehsansz.com',GETDATE())
             SET @counter = @counter + 1
            COMMIT WITH (DELAYED_DURABILITY = ON)
         END
	SELECT DATEDIFF(SECOND, @START, GETDATE() )
END

GO
EXEC Insert_Employees2
GO













--Durability Transaction درج با روش
--به مدت زمان اجرای دستور بررسی شود
BEGIN TRANSACTION
GO
INSERT INTO Employees(FullName,DateAdded) VALUES ('Masoud*Taheri(www.NikAmooz.com)',GETDATE())
GO 100000
GO
COMMIT TRANSACTION
GO
SP_SPACEUSED Employees
GO
--پاک کردن محتوای جدول
TRUNCATE TABLE Employees
GO
--------------------------------------------------------
--DELAYED_DURABILITY فعال سازی  
ALTER DATABASE SQL2014_Demo SET DELAYED_DURABILITY = ALLOWED --FORCED
GO

--Delay Durability Transaction درج با روش
--به مدت زمان اجرای دستور بررسی شود
BEGIN TRANSACTION
GO
INSERT INTO Employees(FullName,DateAdded) VALUES ('Masoud*Taheri(www.NikAmooz.com)',GETDATE())
GO 10000
GO
COMMIT TRANSACTION WITH (DELAYED_DURABILITY=ON)
GO
SP_SPACEUSED Employees
GO
