
/*
Linked Server استفاده از 
دیگر Instance برای اتصال به یک Linked Server ایجاد 
*/
USE master
GO
EXEC sp_addlinkedserver     
   @server=N'SQL2016',   
   @srvproduct=N'',  
   @provider=N'SQLNCLI',   
   @datasrc=N'127.0.0.1\sqlserver2016';
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SQL2016', 
	@locallogin = NULL , @useself = N'False', 
	@rmtuser = N'sa', @rmtpassword = N'123456'
GO
--ها و لاگین های مربوط به آنLinked Server بدست آوردن لیست 
SELECT * FROM SYS.servers
SELECT * FROM SYS.linked_logins
GO
/*
--Linked Server شکل کلی دسترسی به اشیاء در  
LinkedServer.Database.Schema.Objectname
*/
SELECT * FROM LinkedServerName.DatabaseName.dbo.TableName
GO
--------------------------------------------------------------------
/*
Linked Server ساخت جدول در دیتابیس 
SQL Server 2016
*/
GO
USE AdventureworksDW2016CTP3
GO
DROP TABLE IF EXISTS TestStudent
GO
CREATE TABLE TestStudent
(
	StudentID INT PRIMARY KEY,
	FullName NVARCHAR(100)
)
GO
INSERT INTO TestStudent(StudentID,FullName) VALUES
	(1,N'مسعود طاهری')
GO
SELECT * FROM TestStudent
GO
--------------------------------------------------------------------
/*
Linked Server با استفاده از CRUD انجام عملیات 
Show Execution Plan
SQLProfiler (SQLServer2016 ** Filter LoginName=sa)
*/
USE AdventureWorksDW2017
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
/*
ساده Select اجرای یک 
Select Query
Show Execution Query
Show SQL Server Profiler
*/
SELECT 
	* 
FROM SQL2016.AdventureworksDW2016CTP3.dbo.FactInternetSales
GO
/*
ساده با شرط Select اجرای یک 
Select Query
Show Execution Query
Show SQL Server Profiler
*/
SELECT 
	* 
FROM SQL2016.AdventureworksDW2016CTP3.dbo.FactInternetSales
WHERE SalesOrderNumber='SO68464'
GO
/*
ساده با شرط Select اجرای یک 
Select Query
Show Execution Query
Show SQL Server Profiler
بحث تخمین اشتباه
*/
SELECT 
	* 
FROM SQL2016.AdventureworksDW2016CTP3.dbo.FactInternetSales FactInternetSales
INNER JOIN AdventureWorksDW2017..DimCustomer ON
	FactInternetSales.CustomerKey=DimCustomer.CustomerKey
WHERE FactInternetSales.SalesOrderNumber='SO68464'
GO
/*
ساده با شرط Select اجرای یک 
Select Query
Show Execution Query
Show SQL Server Profiler
بحث تخمین اشتباه
Linked Server استفاده هر دو جدول از 
*/
SELECT 
	* 
FROM SQL2016.AdventureworksDW2016CTP3.dbo.FactInternetSales FactInternetSales
INNER JOIN SQL2016.AdventureworksDW2016CTP3.dbo.DimCustomer DimCustomer ON
	FactInternetSales.CustomerKey=DimCustomer.CustomerKey
WHERE FactInternetSales.SalesOrderNumber='SO68464'
GO
-------------------------------------
/*
اجرای دستور برای درج رکورد
Insert Query
Show Execution Query
Show SQL Server Profiler
*/
INSERT INTO SQL2016.AdventureworksDW2016CTP3.dbo.TestStudent(StudentID,FullName) VALUES
	(2,N'فرید طاهری')
GO
/*
اجرای دستور برای درج رکورد
Insert Query
Show Execution Query
Show SQL Server Profiler
*/
INSERT INTO SQL2016.AdventureworksDW2016CTP3.dbo.TestStudent(StudentID,FullName) 
	SELECT 
		object_id,NAME 
	FROM SYS.objects
GO
-------------------------------------
/*
اجرای دستور برای به روز رسانی رکورد
Update Query
Show Execution Query
Show SQL Server Profiler
*/
UPDATE SQL2016.AdventureworksDW2016CTP3.dbo.TestStudent SET
	FullName=N'فرید طاهری*'
WHERE StudentID=2
GO
/*
اجرای دستور برای به روز رسانی رکورد
Update Query
Show Execution Query
Show SQL Server Profiler
*/
UPDATE TestStudent
 SET 
	TestStudent.FullName=OBJ.NAME
FROM SQL2016.AdventureworksDW2016CTP3.dbo.TestStudent TestStudent
INNER JOIN SYS.objects OBJ ON
	TestStudent.StudentID=OBJ.object_id
WHERE TestStudent.StudentID=2
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--OpenQuery استفاده از تابع 
/*
استفاده از آن به جنس کاری که انجام می دهیم بستگی دارد
*/
GO
SELECT 
	FactInternetSales.*
FROM OPENQUERY
(
	SQL2016,
	'SELECT * FROM AdventureworksDW2016CTP3.dbo.FactInternetSales' 
) AS FactInternetSales
GO
--Linked Server استفاده مستقیم از 
SELECT 
	* 
FROM SQL2016.AdventureworksDW2016CTP3.dbo.FactInternetSales
GO
-------------------------------------
--OpenQuery استفاده از تابع 
SELECT 
	FactInternetSales.*
FROM OPENQUERY
(
	SQL2016,
	'SELECT * FROM AdventureworksDW2016CTP3.dbo.FactInternetSales
		WHERE SalesOrderNumber=''SO68464'''
) AS FactInternetSales
GO
--Linked Server استفاده مستقیم از 
SELECT 
	* 
FROM SQL2016.AdventureworksDW2016CTP3.dbo.FactInternetSales
WHERE SalesOrderNumber='SO68464'
GO
-------------------------------------
--OpenQuery استفاده از تابع 
SELECT 
	FactInternetSales.*
FROM OPENQUERY
(
	SQL2016,
	'SELECT * FROM AdventureworksDW2016CTP3.dbo.FactInternetSales
		WHERE SalesOrderNumber=''SO68464'''
) AS FactInternetSales
INNER JOIN AdventureWorksDW2017..DimCustomer ON
	FactInternetSales.CustomerKey=DimCustomer.CustomerKey
GO
--Linked Server استفاده مستقیم از 
SELECT 
	* 
FROM SQL2016.AdventureworksDW2016CTP3.dbo.FactInternetSales FactInternetSales
INNER JOIN AdventureWorksDW2017..DimCustomer ON
	FactInternetSales.CustomerKey=DimCustomer.CustomerKey
WHERE FactInternetSales.SalesOrderNumber='SO68464'
GO