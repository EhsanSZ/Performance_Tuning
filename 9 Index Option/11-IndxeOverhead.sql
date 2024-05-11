
--تاثیر درج و حذف رکوردها در ایندکس ها
--	هنگام درج به روز رساني و حذف ركوردها ايندكس هاي آن نيز به روز مي شود
-- Non Clustered indexes must be updated (maintained) 
-- immediately when the main table is modified:

USE master
GO
--بررسی وجود بانک اطلاعاتی
IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE Test01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test01
END
GO
CREATE DATABASE Test01
GO
USE Test01
GO
DROP TABLE IF EXISTS Employees
GO
CREATE TABLE Employees
(
	ID CHAR(900),
	FirstName NVARCHAR(3000),
	LastName NVARCHAR(3000),
	StartYear CHAR(900)
)
GO
--ایجاد ایندکس ها
CREATE CLUSTERED INDEX IX_Clustered ON Employees(ID)
CREATE NONCLUSTERED INDEX IX_NonClustered ON Employees(StartYear)
GO
--درج رکورد تستی
--Show Execution Plan
SET STATISTICS IO ON
INSERT INTO Employees(ID,FirstName,LastName,StartYear) VALUES (1,'Masoud','Taheri',1378)
GO
--تغییر رفتار لاگ  فایل
ALTER DATABASE Test01 SET RECOVERY SIMPLE 
GO
--انتقال كليه صفحات تغيير يافته از حافظه به ديسك
CHECKPOINT  
GO
--نمايش محتواي لاگ فايل
SELECT * FROM  fn_dblog(null,null) 
GO
--درج رکورد تستی
INSERT INTO Employees(ID,FirstName,LastName,StartYear) VALUES (2,'Farid','Taheri',1378)
GO
--نمايش محتواي لاگ فايل
SELECT * FROM  fn_dblog(null,null) 
GO
----------------------------------------------------------------------------------
--هر چقدر تعداد ایندکس های جدول زیاد باشد کارایی می آید پایین
DECLARE @Cmd VARCHAR(1000)
DECLARE @Cntr INT=1
WHILE @Cntr<=998
BEGIN 
	SET @Cmd='CREATE NONCLUSTERED INDEX IX_'+ CAST(@Cntr AS VARCHAR(100))+' ON Employees(StartYear)'
	PRINT @CMD
	EXEC( @Cmd)
	SET @Cntr+=1
END
GO
--درج یک رکورد تستی
--هم بررسی شودIO
INSERT INTO Employees(ID,FirstName,LastName,StartYear) VALUES (3,'Majid','Taheri',1380)
GO
SELECT * FROM Employees
GO
--انتقال كليه صفحات تغيير يافته از حافظه به ديسك
CHECKPOINT  
GO
--نمايش محتواي لاگ فايل
SELECT * FROM  fn_dblog(null,null) 
GO
--درج یک رکورد تستی
INSERT INTO Employees(ID,FirstName,LastName,StartYear) VALUES (4,'Majid','Taheri',1380)
GO
--نمايش محتواي لاگ فايل
SELECT * FROM  fn_dblog(null,null) 
GO
-----------------------------
--حالا تعدادی از رکوردهای را می خواهیم حذف کنیم
--حالا تعداد لاگ های ثبت شده را بررسی کنید
GO
SET STATISTICS IO OFF
GO
--درج تعدادی رکورد
DECLARE @Cmd VARCHAR(1000)
DECLARE @Cntr INT=10
WHILE @Cntr<=200
BEGIN
	INSERT INTO Employees(ID,FirstName,LastName,StartYear) VALUES (CAST(@Cntr AS CHAR(900)),'Alireza','Taheri',1392)
	SET @Cntr+=1
END
GO
--دیگر Session بررسی در یک 
Sp_SPACEUSED Employees
GO
CHECKPOINT
GO
BEGIN TRANSACTION
DELETE FROM Employees WHERE ID BETWEEN '100' AND '150'
SELECT
	database_transaction_log_record_count,
	database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID('Test01')
ROLLBACK
GO
--تولید لاگی  در حدود 100 مگابایت