
--Parameter Sniffing

USE Northwind
GO
SET STATISTICS IO ON
GO
--Show Actual Plan
SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders	
	WHERE CustomerID='CENTC' 
GO
SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders	
	WHERE CustomerID='SAVEA' 
GO
SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders	
	WHERE CustomerID='BONAP' 
GO
--ایجاد یک پروسیجر و قرار دادن کوئری فوق در آن
IF OBJECT_ID('usp_GetOrders0')>0
	DROP PROCEDURE usp_GetOrders0
GO
CREATE PROCEDURE usp_GetOrders0 (@CustomerID NCHAR(5))
AS
	SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders	
		WHERE CustomerID=@CustomerID 
GO
--فراخوانی پروسیجر با پارامترهای مختلف 
--Show Actual Plan
EXEC usp_GetOrders0 'CENTC'
EXEC usp_GetOrders0 'SAVEA'
EXEC usp_GetOrders0 'BONAP'
GO
DBCC FREEPROCCACHE
GO
--فراخوانی پروسیجر با پارامترهای مختلف 
--Show Actual Plan
--اجرای پروسیجر
/*
Execution Plan بررسی 
Select Properties قسمت 
**
Parameter List توجه به قسمت 
Parameter Compiled Value
Parameter Run Value
*/
EXEC usp_GetOrders0 'SAVEA'
EXEC usp_GetOrders0 'CENTC'
EXEC usp_GetOrders0 'BONAP'
GO
--------------------------------------------------------------------
--رفع مشکل

--Recompile استفاده از گزينه
IF OBJECT_ID('usp_GetOrders1')>0
	DROP PROCEDURE usp_GetOrders1
GO
CREATE PROCEDURE usp_GetOrders1 (@CustomerID NVARCHAR(10))
AS
	SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders	
		WHERE CustomerID=@CustomerID 
	OPTION (RECOMPILE)		
GO
--اجرای هر سه پروسیجر
EXEC usp_GetOrders1 'CENTC'
EXEC usp_GetOrders1 'SAVEA'
EXEC usp_GetOrders1 'BONAP'
GO
--****************************
--Optimize For استفاده از گزينه
--پلن به ازاي شرايط فوق بهينه و در صورتيكه در شرط صدق نكند مجددا پلن به ازاي درخواست ايجاد مي شود	
GO
IF OBJECT_ID('usp_GetOrders2')>0
	DROP PROCEDURE usp_GetOrders2
GO
CREATE PROCEDURE usp_GetOrders2 (@CustomerID NVARCHAR(10))
AS
	SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders	
		WHERE CustomerID=@CustomerID 
	OPTION (RECOMPILE,OPTIMIZE FOR (@CustomerID='SAVEA'))	
GO
--اجرای هر سه پروسیجر
EXEC usp_GetOrders2 'CENTC'
EXEC usp_GetOrders2 'SAVEA'
EXEC usp_GetOrders2 'BONAP'
GO
--****************************
--Optimize For Unknown استفاده از گزينه
GO
IF OBJECT_ID('usp_GetOrders3')>0
	DROP PROCEDURE usp_GetOrders3
GO
CREATE PROCEDURE usp_GetOrders3 (@CustomerID NVARCHAR(10))
AS
	SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders	
		WHERE CustomerID=@CustomerID 
	OPTION (OPTIMIZE FOR (@CustomerID UNKNOWN))		
GO
--اجرای هر سه پروسیجر
EXEC usp_GetOrders3 'CENTC'
EXEC usp_GetOrders3 'SAVEA'
EXEC usp_GetOrders3 'BONAP'
GO
--****************************
--sp_Executesql استفاده از 
--همیشه مفید نمی باشد
GO
USE Northwind
GO
IF OBJECT_ID('usp_GetOrders4')>0
	DROP PROCEDURE usp_GetOrders4
GO
CREATE PROCEDURE usp_GetOrders4 (@CustomerID NCHAR(5))
AS
	DECLARE @cmd NVARCHAR(1000)
	SET @cmd=N'SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders WHERE CustomerID=@CustomerID'
	EXEC sp_executesql @cmd,N'@CustomerID NCHAR(5)', @CustomerID=@CustomerID
GO

--اجرای هر سه پروسیجر
EXEC usp_GetOrders4 'CENTC'
EXEC usp_GetOrders4 'SAVEA'
EXEC usp_GetOrders4 'BONAP'
GO
--****************************
--sp_Executesql استفاده از 
-- OPTION (RECOMPILE) به همراه 
--درگیر هستید Parameter Sniffing زمانی استفاده شود که با  
GO
USE Northwind
GO
IF OBJECT_ID('usp_GetOrders4_1')>0
	DROP PROCEDURE usp_GetOrders4_1
GO
CREATE PROCEDURE usp_GetOrders4_1 (@CustomerID VARCHAR(10))
AS
	DECLARE @cmd NVARCHAR(1000)
	SET @cmd=N'SELECT OrderID, CustomerID, OrderDate, ShipCountry FROM Orders WHERE CustomerID=@CustomerID OPTION (RECOMPILE)'
	EXEC sp_executesql @cmd,N'@CustomerID VARCHAR(10)', @CustomerID=@CustomerID
GO

--اجرای هر سه پروسیجر
EXEC usp_GetOrders4_1 'CENTC'
EXEC usp_GetOrders4_1 'SAVEA'
EXEC usp_GetOrders4_1 'BONAP'
GO
--------------------------------------------------------------------------------------------------------
--كامپايل كردن پروسيجرها به روش هاي مختلف امكان پذير است
DBCC FREEPROCCACHE --پاك كردن كش مربوط به پروسيجرهاو .... به ازاي كليه بانك هاي اطلاعاتي مي باشد
GO
EXEC usp_GetOrders0 'CENTC'	              --logical reads 4
EXEC usp_GetOrders0 'CENTC' WITH RECOMPILE--logical reads 4
GO
EXEC usp_GetOrders0 'SAVEA'				  --logical reads 64
EXEC usp_GetOrders0 'SAVEA' WITH RECOMPILE--logical reads 22
GO
EXEC usp_GetOrders0 'BONAP'				  --logical reads 36
EXEC usp_GetOrders0 'BONAP' WITH RECOMPILE--logical reads 22
GO
--SP_RECOMPILE يا با استفاده از پروسيجر
EXEC SP_RECOMPILE 'usp_GetOrders0'
GO
-- زمانيكه يك ايندكس به جدول اضافه كرديد جهت كامپايل پروسيجرهاي تحت تاثير استفاده SP_RECOMPILEاز دستور  
--نماييد
--------------------------------------------------------------------------------------------------------
--استفاده از پروسیجرهایی که عمومی نوشته  شده اند
GO
SET STATISTICS IO ON 
GO
USE AdventureWorks2017
GO
--ساختن پروسیجر
IF OBJECT_ID('usp_GetSalesOrderHeader0')>0
	DROP PROCEDURE usp_GetSalesOrderHeader0
GO
CREATE PROCEDURE usp_GetSalesOrderHeader0 (@SalesOrderID INT,@OrderDate DATETIME)
AS
	SELECT * FROM Sales.SalesOrderHeader
		WHERE (SalesOrderID=@SalesOrderID OR @SalesOrderID IS NULL)
		AND  (OrderDate=@OrderDate OR @OrderDate IS NULL)
GO
--فراخوانی پروسیجر
--حالت اول
EXEC usp_GetSalesOrderHeader0 43671,NULL
GO
--حالت دوم
EXEC usp_GetSalesOrderHeader0 NULL,'2005-07-01 00:00:00.000'
GO
--حالت سوم
EXEC usp_GetSalesOrderHeader0 43671,'2005-07-01 00:00:00.000'
GO
--حالت چهارم
EXEC usp_GetSalesOrderHeader0 NULL,NULL
GO
-------------------
--Show Actual Plan
--حالت اول
SELECT 
	* 
FROM Sales.SalesOrderHeader
WHERE 
	(SalesOrderID=43671)
GO
--حالت دوم
SELECT 
	* 
FROM Sales.SalesOrderHeader
WHERE 
	(OrderDate='2005-07-01 00:00:00.000')
GO
--حالت سوم
SELECT 
	* 
FROM Sales.SalesOrderHeader
WHERE 
	(SalesOrderID=43671) AND(OrderDate='2005-07-01 00:00:00.000')
GO
--حالت چهارم
SELECT 
	* 
FROM Sales.SalesOrderHeader
GO
-------------------
--رفع مشکل
IF OBJECT_ID('usp_GetSalesOrderHeader1')>0
	DROP PROCEDURE usp_GetSalesOrderHeader1
GO
CREATE PROCEDURE usp_GetSalesOrderHeader1 (@SalesOrderID INT,@OrderDate DATETIME)
AS
	DECLARE @cmd NVARCHAR(1000)
	SET @cmd=N'SELECT * FROM Sales.SalesOrderHeader WHERE 1=1 '

	IF @SalesOrderID IS NOT NULL
		SET @cmd+=' AND SalesOrderID=@SalesOrderID'

	IF @OrderDate IS NOT NULL
		SET @cmd+=' AND OrderDate=@OrderDate'
	
	EXEC sp_executesql @cmd
		,N'@SalesOrderID INT,@OrderDate DATETIME', 
		@SalesOrderID,@OrderDate
GO
EXEC usp_GetSalesOrderHeader1 43671,NULL
EXEC usp_GetSalesOrderHeader1 NULL,'2005-07-01 00:00:00.000'
EXEC usp_GetSalesOrderHeader1 43671,'2005-07-01 00:00:00.000'
EXEC usp_GetSalesOrderHeader1 NULL,NULL
GO
GO
GO