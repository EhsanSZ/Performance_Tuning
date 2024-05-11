
--Step 01
USE master
GO
--ساخت بانک اطلاعاتی
IF DB_ID('Test_Shrink')>0
BEGIN
	ALTER DATABASE Test_Shrink SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test_Shrink
END
GO
CREATE DATABASE Test_Shrink
GO
--ساخت جداول تستی
USE Test_Shrink
GO
DROP TABLE IF EXISTS Employees1
DROP TABLE IF EXISTS Employees2
GO
CREATE TABLE Employees1
(
	EmployeeID INT IDENTITY(1,1),
	SSN INT,
	FirstName NCHAR(2000),
	LastName NCHAR(2000),
	CONSTRAINT PK_Employees1 PRIMARY KEY (EmployeeID),
	CONSTRAINT UK_SSN1 UNIQUE (SSN)
)
GO
CREATE TABLE Employees2
(
	EmployeeID INT IDENTITY(1,1),
	SSN INT,
	FirstName NCHAR(2000),
	LastName NCHAR(2000),
	CONSTRAINT PK_Employees2 PRIMARY KEY (EmployeeID),
	CONSTRAINT UK_SSN2 UNIQUE (SSN)
)
GO
--درج تعدادی رکورد تستی در هر دو جدول
DECLARE @C INT=1
DECLARE @FirstName NCHAR(2000)=''
DECLARE @LastName NCHAR(2000)=''
WHILE @C<=10000
BEGIN
	SET @FirstName='FirstName' + CAST(@C AS NVARCHAR(10))
	SET @LastName='LastName' + CAST(@C AS NVARCHAR(10))
	INSERT INTO Employees1(SSN,FirstName,LastName) VALUES (@C,@FirstName,@LastName)
	INSERT INTO Employees2(SSN,FirstName,LastName) VALUES (@C,@FirstName,@LastName)
	SET @C+=1
END
GO
--بررسی حجم جداول
SP_HELPINDEX Employees1
GO
SP_HELPINDEX Employees2
GO
SELECT * FROM Employees1
SELECT * FROM Employees2
GO
--حذف جدول دوم
DROP TABLE Employees2
GO
--Fragmentation مشاهده وضعیت 
SELECT index_type_desc,Avg_Fragmentation_In_Percent
	FROM sys.dm_db_index_physical_stats 
		(
			DB_ID ('Test_Shrink'), OBJECT_ID ('Employees1'), NULL, NULL, 'Limited'
		)
GO
SET STATISTICS IO ON
SELECT * FROM Employees1
SET STATISTICS IO OFF
GO
--کردن دیتابیس Shrink
DBCC SHRINKDATABASE (Test_Shrink)
GO
/*
--انجام هر كدام از دستورات فوق به ضرر ايندكس ها است
DBCC SHRINKDATABASE (Test_Shrink);
DBCC SHRINKDATABASE (Test_Shrink,NOTRUNCATE);--آخرين فضاي پر به اولين فضاي خالي مي رود
DBCC SHRINKFILE (Test_Shrink);
DBCC SHRINKFILE (Test_Shrink,NOTRUNCATE);--آخرين فضاي پر به اولين فضاي خالي مي رود
*/
GO
--Fragmentation مشاهده وضعیت 
SELECT index_type_desc,Avg_Fragmentation_In_Percent
	FROM sys.dm_db_index_physical_stats 
		(
			DB_ID ('Test_Shrink'), OBJECT_ID ('Employees1'), NULL, NULL, 'Limited'
		)
GO
--Auto Shrinkبررسی 