
--ساخت بانک اطلاعاتی برای بررسی فایل های مربوط به آن
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
--استفاده کنیمText,NText,Image چرا نباید از دیتا تایپ 
--دلیل 1
GO
USE MyDB2017
GO
--بررسی وجود جدول
IF OBJECT_ID('Table1')>0
	DROP TABLE Table1
GO
--ایجاد جدول
CREATE TABLE Table1
(
	ID INT IDENTITY PRIMARY KEY,
	InsertDate DATETIME,
	Comments TEXT
)
GO
IF OBJECT_ID('Table2')>0
	DROP TABLE Table2
GO
--ایجاد جدول
CREATE TABLE Table2
(
	ID INT IDENTITY PRIMARY KEY,
	InsertDate DATETIME,
	Comments VARCHAR(MAX)
)
GO
--بررسی ایندکس های هر دو جدول
EXEC sp_helpindex Table1
EXEC sp_helpindex Table2
GO
--درج رکورد های تستی در هر دو جدول
INSERT INTO Table1(InsertDate,Comments) VALUES (GETDATE(),'Ehsan Seyedzadeh')
GO 1000
INSERT INTO Table2(InsertDate,Comments) VALUES (GETDATE(),'Ehsan Seyedzadeh')
GO 1000
--بررسی حجم رکوردهای موجود در جداول
EXEC sp_spaceused Table1
EXEC sp_spaceused Table2
GO
--IO بررسی وضعیت 
SET STATISTICS IO ON 
SELECT * FROM Table1
SELECT * FROM Table2
SET STATISTICS IO OFF
GO
--Execution Plan مقایسه
SELECT * FROM Table1
SELECT * FROM Table2
GO
--دلیل 2
SELECT * FROM Table1 WHERE Comments='Ehsan Seyedzadeh'
SELECT * FROM Table2 WHERE Comments='Ehsan Seyedzadeh'
GO
--دلیل 3
ALTER INDEX ALL ON Table1 REBUILD WITH(ONLINE=ON)
ALTER INDEX ALL ON Table2 REBUILD WITH(ONLINE=ON)
GO
