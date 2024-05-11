
USE AdventureWorks2017
GO
--آماده سازی جداول مورد نیاز
DROP TABLE IF EXISTS SalesOrderDetail2
GO
SELECT * INTO SalesOrderDetail2 FROM Sales.SalesOrderDetail
GO
SP_HELPINDEX SalesOrderDetail2
GO
SP_SPACEUSED SalesOrderDetail2
GO
----------------------------------
/*
Execution Plan نمایش 
فقط تفاوت در پلن بررسی شده و هزینه آن شرح داده شود
*/
GO
SET STATISTICS IO ON 
--Scan بررسی عملیات 
--Table Scan
SELECT * FROM SalesOrderDetail2 WHERE SalesOrderID=43668
GO
--Seek بررسی عملیات 
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID=43668
GO
--Scan بررسی عملیات 
--Clustered Index Scan
SELECT * FROM Sales.SalesOrderDetail WHERE OrderQty=5
GO