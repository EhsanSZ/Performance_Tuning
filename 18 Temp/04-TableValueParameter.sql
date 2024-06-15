
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('Temp_Test')>0
BEGIN
	ALTER DATABASE Temp_Test SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Temp_Test
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE Temp_Test
GO
USE Temp_Test
GO
CREATE TABLE [Order]
(
	OrderId INT IDENTITY PRIMARY KEY,
	CustomerId INT NOT NULL,
	OrderDate DATETIME NOT NULL
 )
GO
CREATE TABLE [OrderDetail]
(
	ID INT IDENTITY PRIMARY KEY,
	OrderId INT REFERENCES [Order](OrderId) ,
	ProductId INT NOT NULL,
	Quantity INT NOT NULL,
	Price MONEY NOT NULL
)
GO

GO
CREATE TYPE OrderDetailUdt AS TABLE
(
	ProductId INT NOT NULL,
	Quantity INT NOT NULL,
	Price MONEY NOT NULL
)
GO
------------------------------------------------
--تست نوع داده جدولي
DECLARE @O_D AS OrderDetailUdt;
INSERT INTO @O_D VALUES (100,2,100000);
INSERT INTO @O_D VALUES (101,20,300000);
INSERT INTO @O_D VALUES (102,7,20000);
INSERT INTO @O_D VALUES (103,10,40000);
SELECT 1 CustoemrID,Getdate() OrderDate 
SELECT * FROM @O_D;
------------------------------------------------
--ايجاد روال براي درج سفارش
CREATE OR ALTER PROCEDURE InsertOrders
(
	@CustomerId INT ,@OrderDate DATETIME ,
	@OrderDetails AS OrderDetailUdt READONLY
)
AS
	BEGIN
		
		BEGIN TRY
			BEGIN TRAN
				DECLARE @OrderId INT;
				INSERT INTO [Order](CustomerId,OrderDate) VALUES
					(@CustomerId,@OrderDate)
				--Fetch Identity
				SELECT @OrderId=SCOPE_IDENTITY();
				-- Batch insert order detail rows from TVP
				INSERT INTO [OrderDetail](OrderId,ProductId,Quantity,Price) 
					SELECT @OrderId,ProductId,Quantity,Price  FROM @OrderDetails;
			COMMIT TRAN
		END TRY
		BEGIN CATCH 
			ROLLBACK TRAN 
		END CATCH
	 END
GO
-----------------------------------------------
--درج داده بوسيله دستورات اس كيو ال 
DECLARE @O_D AS OrderDetailUdt;
INSERT INTO @O_D VALUES (100,2,100000);
INSERT INTO @O_D VALUES (101,20,300000);
--INSERT INTO @O_D VALUES (102,7,20000);
--INSERT INTO @O_D VALUES (103,10,40000);
DECLARE @D DATETIME=GETDATE()
EXEC InsertOrders 1,@D,@O_D;
GO
SELECT * FROM [Order]
SELECT * FROM [OrderDetail]
-------------------------------------------------
--درج داده از طريق سي شارپ
--همانند ساختار نوع داده جدولي دو ديتا تيبل ايجاد شود
/*
var headers = new DataTable();
headers.Columns.Add("CustomerId", typeof(int));
headers.Columns.Add("OrderDate", typeof(DateTime));

var details = new DataTable();
details.Columns.Add("ProductId", typeof(int));
details.Columns.Add("Quantity", typeof(decimal));
details.Columns.Add("Price", typeof(int));

headers.Rows.Add(new object[] { 1, DateTime.Today });

details.Rows.Add(new object[] { 100,2,100000 });
details.Rows.Add(new object[] { 101,20,300000 });
details.Rows.Add(new object[] { 102,7,20000 });
details.Rows.Add(new object[] { 103,10,40000 });



using (var conn = new SqlConnection("Data Source=.;Initial Catalog=MyDb;Integrated Security=True;"))
{
  conn.Open();
  using (var cmd = new SqlCommand("InsertOrders", conn))
  {
    cmd.CommandType = CommandType.StoredProcedure;

    var headersParam = cmd.Parameters.AddWithValue("@OrderHeaders", headers);
    var detailsParam = cmd.Parameters.AddWithValue("@OrderDetails", details);

    headersParam.SqlDbType = SqlDbType.Structured;
    detailsParam.SqlDbType = SqlDbType.Structured;

    cmd.ExecuteNonQuery();
  }
  conn.Close();
}
*/
-------------------------------------------------------------------------------
/*
STRING_SPLIT استفاده از تابع 
*/
DECLARE @tags NVARCHAR(400) = 'A,B,,C,D'  
SELECT 
	value  
FROM STRING_SPLIT(@tags, ',')  
GO
-------------------------------------------------------------------------------
USE AdventureWorks2017
GO
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
GO
SELECT 
	* 
FROM Sales.SalesOrderHeader 
WHERE CustomerID IN 
(
	11020,
	11021,
	11022,
	11023,
	20746,
	20747,
	20748,
	20749,
	20750,
	20751,
	20752,
	28485,
	28486,
	28487,
	28488
)
GO
-------------------------------------------------------------------------------
USE AdventureWorks2017
GO
CREATE TYPE CustomerType AS TABLE
(
	CustomerId INT NOT NULL
)
GO
----Stored Procedure 
DECLARE @TVP_CustomerType CustomerType
INSERT INTO @TVP_CustomerType VALUES
	(11020),
	(11021),
	(11022),
	(11023),
	(20746),
	(20747),
	(20748),
	(20749),
	(20750),
	(20751),
	(20752),
	(28485),
	(28486),
	(28487),
	(28488)	
SELECT * FROM Sales.SalesOrderHeader  INNER JOIN  @TVP_CustomerType TVP
	ON SalesOrderHeader.CustomerID=TVP.CustomerID OPTION (RECOMPILE)
GO
USE AdventureWorks2017
GO
DECLARE @tags NVARCHAR(400) = '11020,11021,11022,11023,20746,20747,20748,20749,20750,20751,20752,28485,28486,28487,28488'  
SELECT 
	*  
FROM Sales.SalesOrderHeader H
INNER JOIN STRING_SPLIT(@tags, ',')   S ON
	H.CustomerID=CAST(S.value AS INT)
GO
-------------------------------------------------------------------------------
USE Northwind
GO
SELECT TOP 10
	CustomerID,CompanyName 
FROM Customers FOR JSON AUTO
GO
DECLARE @S NVARCHAR(MAX)
SET @S=
(
SELECT TOP 10
	CustomerID,CompanyName 
FROM Customers FOR JSON AUTO
)
PRINT @S
--JSON استفاده از 
SELECT  
 *
FROM
OPENJSON(@S)WITH (CustomerID NVARCHAR(10), CompanyName NVARCHAR(30))

	  --OpenJson()WITH (CustomerID INT '$.number', Word VARCHAR(30) '$.word')

-----------------

USE DemoPageOrganization
GO
SELECT
	EmployeeKey,COUNT(EmployeeKey) AS RecCount 
FROM ClusteredTable
GROUP BY EmployeeKey

DROP TABLE IF EXISTS #T 
CREATE TABLE #T(EmployeeKey INT,RecCount INT)

INSERT INTO #T 
	SELECT EmployeeKey,COUNT(EmployeeKey) AS RecCount FROM ClusteredTable
	GROUP BY EmployeeKey

DECLARE @T TABLE (EmployeeKey INT,RecCount INT)

INSERT INTO @T 
	SELECT EmployeeKey,COUNT(EmployeeKey) AS RecCount FROM ClusteredTable
	GROUP BY EmployeeKey