
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
--------------------------------------------------------------------
/*
ایجاد جدول اول به صورت یکتا با یک فیلد عدد
*/
USE  MyDB2017
GO
DROP TABLE IF EXISTS Employees
GO
CREATE TABLE Employees
(
	ID CHAR(900) ,
	FirstName CHAR(3500),
	LastName CHAR(3500)
)
GO
--ساخت ایندکس
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON Employees(ID)
GO
--درج تعدادی رکورد تستی
INSERT INTO Employees(ID,FirstName,LastName) VALUES (1,'Masoud','Taheri')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (5,'Alireza','Taheri')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (3,'Ali','Taheri')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (4,'Majid','Taheri')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (2,'Farid','Taheri')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (10,'Ahmad','Ghafari')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (8,'Alireza','Nasiri')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (9,'Khadijeh','Afrooznia')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (7,'Mina','Afrooznia')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (6,'Mohammad','Noroozi')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (11,'Saeed','Safai')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (12,'Hesam','Nabavi')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (13,'Saber','Navai')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (14,'Ali','Darabi')
INSERT INTO Employees(ID,FirstName,LastName) VALUES (15,'Pedrm','Nasiri')
GO
--مشاهده رکوردهای موجود در جدول
SELECT * FROM Employees
GO
--آنالیز ایندکس
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('Employees'),
	1,
	NULL,
	'DETAILED'
)
GO
---------------------------------
/*
IO , Execution Plan بررسی 
*/
SET STATISTICS IO ON
GO
SELECT * FROM Employees WHERE ID='5'
GO
SELECT * FROM Employees WHERE ID=5
--------------------------------------------------------------------
/*
مثال دیگر 
IO , Execution Plan بررسی 
*/
USE AdventureWorks2017
GO
DROP TABLE IF EXISTS SalesOrderHeader2 
GO
SELECT * INTO SalesOrderHeader2 FROM Sales.SalesOrderHeader
GO
--ساخت ایندکس کلاستر
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON SalesOrderHeader2(SalesOrderID)
GO
--بررسی حجم
SP_SPACEUSED SalesOrderHeader2
GO
--آنالیز ایندکس
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks2017'),
	OBJECT_ID('SalesOrderHeader2'),
	1,
	NULL,
	'DETAILED'
)
GO
---------------------------------
--IO , Execution Plan بررسی 
SET STATISTICS IO ON 
GO
SELECT * FROM SalesOrderHeader2 WHERE SalesOrderID=52244
GO
SELECT * FROM SalesOrderHeader2 WHERE SalesOrderID BETWEEN 52244 AND  52344
GO
SELECT * FROM SalesOrderHeader2  WHERE SalesPersonID=282
GO

