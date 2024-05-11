
/*
NonClustered Index بررسی ساخت 999 تا  
SQL Server بررسی افزایش طول کلید ایندکس در 
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
--حذف جدول
DROP TABLE IF EXISTS Employees
GO
--ایجاد جدول
CREATE TABLE Employees
(
	ID CHAR(900),
	FirstName NVARCHAR(3000),
	LastName NVARCHAR(3000),
	StartYear CHAR(900)
)
GO
--------------------------------------------------------------------
--NonClustered Index بررسی ساخت 999 تا  
USE MyDB2017
GO
DECLARE @Cmd VARCHAR(1000)
DECLARE @Cntr INT=1
WHILE @Cntr<=1000
BEGIN 
	SET @Cmd='CREATE NONCLUSTERED INDEX IX_'+ CAST(@Cntr AS VARCHAR(100))+' ON Employees(StartYear)'
	PRINT @CMD
	EXEC( @Cmd)
	SET @Cntr+=1
END
GO
--بررسی وجود ایندکس ها
SP_HELPINDEX Employees
GO
/*
در بحث NonClustered اشکال ساخت تعداد زیادی ایندکس
مطرح می شودIndex Overhead
*/
GO
--------------------------------------------------------------------
/*
SQL Server بررسی افزایش طول کلید ایندکس در 
تست در حالت های
CHAR,NCHAR,NVARCHAR,
*/
USE MyDB2017
GO
--حذف جدول
DROP TABLE IF EXISTS Employees
GO
--ایجاد جدول
CREATE TABLE Employees
(
	ID CHAR(900),
	FirstName NVARCHAR(3000),
	LastName NVARCHAR(3000),
	QRCode NVARCHAR(1700)  --NCHAR,NVARCHAR
)
GO
CREATE INDEX IX_QRCode ON Employees(QRCode)
GO