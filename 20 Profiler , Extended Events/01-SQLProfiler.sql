
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
--------------------------------------------------------------------
--مشاهده پلن اجرايي يك كوري
--Please HighLight This Query And Press Ctrl+L
USE Northwind
GO
SELECT Customers.CustomerID,Customers.CompanyName,COUNT(Orders.OrderID) AS ORDER_COUNT FROM Customers 
	INNER JOIN Orders 
		ON Customers.CustomerID=Orders.CustomerID 
			GROUP BY Customers.CustomerID,Customers.CompanyName
GO	
--------------------------------------------------------------------
--Stored Procedure نحوه ايجاد يك 
USE MyDB2017
GO
CREATE OR ALTER PROCEDURE ShowMsg
(
	@FirstName  NvarChar(20),
	@LastName  NvarChar(20)
)
AS	
	DECLARE @Ucase_FirstName AS NVARCHAR(20)
	DECLARE @UCase_LastName  AS NVARCHAR(20)
	DECLARE @ResultString  AS NVARCHAR(100)
	
	SET @Ucase_FirstName=UPPER(@FirstName)
	SET @UCase_LastName=UPPER(@LastName)
	SET @ResultString ='Hello ' + @Ucase_FirstName + ' ' + @UCase_LastName  
	
	SELECT @ResultString
Go
--Stored Procedure نحوه اجراي يك 
EXEC ShowMsg 'Masoud','Taheri'
GO
--------------------------------------------------------------------
-- شده ENC به شكل SP ايجاد  
USE MyDB2017
GO
CREATE OR ALTER PROCEDURE ShowMsg
(
	@FirstName  NvarChar(20),
	@LastName  NvarChar(20)
)
	WITH ENCRYPTION
AS	
	DECLARE @Ucase_FirstName AS NVARCHAR(20)
	DECLARE @UCase_LastName  AS NVARCHAR(20)
	DECLARE @ResultString  AS NVARCHAR(100)
	
	SET @Ucase_FirstName=UPPER(@FirstName)
	SET @UCase_LastName=UPPER(@LastName)
	SET @ResultString ='Hello ' + @Ucase_FirstName + ' ' + @UCase_LastName  
	
	SELECT @ResultString
GO
--Stored Procedure نحوه اجراي يك 
EXEC ShowMsg 'Masoud','Taheri'
GO
--------------------------------------------------------------------
