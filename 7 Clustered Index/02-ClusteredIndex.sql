
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
USE MyDB2017
GO
--بررسی وجود جدول
DROP TABLE IF EXISTS ClusteredTable
GO
--Clustered ایجاد یک جدول از نوع
CREATE TABLE ClusteredTable
(
	ID INT,
	FirstName CHAR(2000),
	LastName CHAR(2000)
)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable 
GO
--درج تعدادی رکورد تستی
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (1,'Masoud','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (5,'Alireza','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (3,'Ali','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (4,'Majid','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (2,'Farid','Taheri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (10,'Ahmad','Ghafari')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (8,'Alireza','Nasiri')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (9,'Khadijeh','Afrooznia')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (7,'Mina','Afrooznia')
INSERT INTO ClusteredTable(ID,FirstName,LastName) VALUES (6,'Mohammad','Noroozi')
GO
-- مشاهده داده های موجود در جدول 
--رکوردها نظم و ترتیب ندارند
SELECT * FROM ClusteredTable
GO
/*
Show Actual Execution Plan
*/
SP_SPACEUSED ClusteredTable 
GO
-------------------------------------------------------
--ایجاد کلاستر ایندکس بر روی جدول
--پلن ساخت ایندکس دیده شود
CREATE CLUSTERED INDEX Clustered_IX ON ClusteredTable(ID)
GO
SELECT * FROM ClusteredTable
GO
SP_SPACEUSED ClusteredTable 
GO
--------------------------------------------------------------------
/*
بررسی صفحات تخصیص داده شده به ایندکس
ها Index Page بررسی 
*/
--صحفات وابسته به جدول
SELECT 
	page_type_desc,allocated_page_page_id,
	next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('ClusteredTable'),
		NULL,NULL,'DETAILED'
	)
GO