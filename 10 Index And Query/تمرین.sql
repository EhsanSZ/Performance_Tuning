CREATE TABLE TranLog 
(
	ID INT IDENTITY,
	TranDate	Date,
	TranTime	Time(0),
	RRN	BigInt,
	Amount	Decimal(18,0),
	TranType	Tinyint
)

CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON TranLog(TranDate,ID)
GO
CREATE UNIQUE NONCLUSTERED INDEX IX_RRN ON TranLog(RRN)
	WITH (IGNORE_DUP_KEY=ON)
GO


USE MyDB2017
GO
DROP TABLE IF EXISTS Students
CREATE TABLE Students
(
	StudentID INT IDENTITY,
	FullName TEXT DEFAULT 'NikAmooz',
)
GO
INSERT INTO Students DEFAULT VALUES
GO 10000

CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON Students(StudentID) WITH (ONLINE=ON)
GO

USE AdventureWorks2017
DROP TABLE IF EXISTS SalesOrderHeader2
SELECT * INTO SalesOrderHeader2  FROM Sales.SalesOrderHeader

SELECT * FROM SalesOrderHeader2

ALTER TABLE SalesOrderHeader2 ADD OrderYear AS DATEPART(YEAR,OrderDate) PERSISTED

CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON SalesOrderHeader2(SalesOrderID)
CREATE INDEX IX_OrderYear ON SalesOrderHeader2(OrderYear)

SELECT 
	SalesOrderID,CustomerID,OrderYear 
FROM SalesOrderHeader2 
WHERE 
	OrderYear=2015
GO
SELECT 
	SalesOrderID,CustomerID,
	DATEPART(YEAR,OrderDate) 
FROM Sales.SalesOrderHeader 
WHERE  
	DATEPART(YEAR,OrderDate)=2015


-------------------------

USE MyDB2017
GO
DROP TABLE IF EXISTS Students
GO
CREATE TABLE Students
(
	StudentID INT IDENTITY PRIMARY KEY,
	FullName CHAR(500),
	CityID BIGINT ,
	PostalCode CHAR(50)
)
GO
INSERT INTO Students(FullName,CityID,PostalCode) 
	SELECT name,OBJECT_ID, type_desc FROM SYS.all_objects
GO
SELECT * FROM Students
GO
ALTER TABLE Students ADD ChecksumCol AS CHECKSUM(CityID,PostalCode) PERSISTED	

CREATE INDEX IX_ChecksumCol ON Students(ChecksumCol)

SELECT * FROM Students WHERE ChecksumCol= CHECKSUM(123,'P1')
SELECT * FROM Students WHERE CHECKSUM(CityID,PostalCode)=3813
	
-------------------------
USE Northwind
GO
SELECT 
	OrderID,
	OrderDate,
	Customers.CustomerID,
	Customers.CompanyName
FROM Orders
INNER JOIN Customers ON
	Orders.CustomerID=Customers.CustomerID
GO

SELECT 
	Customers.CustomerID,
	Customers.CompanyName,
	COUNT(Orders.OrderID) AS OrderCount
FROM Orders
INNER JOIN Customers ON
	Orders.CustomerID=Customers.CustomerID
GROUP BY 
	Customers.CustomerID,
	Customers.CompanyName
ORDER BY
	Customers.CustomerID,
	Customers.CompanyName
GO



SELECT name,is_auto_shrink_on FROM SYS.DATABASES