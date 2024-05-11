
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
DROP TABLE IF EXISTS Students
GO
--Clustered ایجاد یک جدول از نوع
CREATE TABLE Students
(
	ID INT NOT NULL ,
	FirstName CHAR(2000),
	LastName CHAR(2000)
)
GO
--بررسی ایندکس های جدول
SP_HELPINDEX Students 
GO
--درج تعدادی رکورد تستی
INSERT INTO Students(ID,FirstName,LastName) values (1,'Masoud','Taheri')
INSERT INTO Students(ID,FirstName,LastName) values (5,'Alireza','Taheri')
INSERT INTO Students(ID,FirstName,LastName) values (3,'Ali','Taheri')
INSERT INTO Students(ID,FirstName,LastName) values (4,'Majid','Taheri')
INSERT INTO Students(ID,FirstName,LastName) values (2,'Farid','Taheri')
INSERT INTO Students(ID,FirstName,LastName) values (10,'Ahmad','Ghafari')
INSERT INTO Students(ID,FirstName,LastName) values (8,'Alireza','Nasiri')
INSERT INTO Students(ID,FirstName,LastName) values (9,'Khadijeh','Afrooznia')
INSERT INTO Students(ID,FirstName,LastName) values (7,'Mina','Afrooznia')
INSERT INTO Students(ID,FirstName,LastName) values (6,'Mohammad','Noroozi')
GO
-- مشاهده داده های موجود در جدول 
--رکوردها نظم و ترتیب ندارند
SELECT * FROM Students
GO
SP_SPACEUSED Students 
GO
--PK آنالیز ایندکس قبل از اعمال 
SELECT 
	index_id,index_type_desc,
	index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('Students'),
	NULL,
	NULL,
	'DETAILED'
)
-------------------------------------------------------
/*
بر روی جدول Primary Key ایجاد 
بررسی وضعیت ایندکس
*/
USE MyDB2017
GO
--Priamry Key اعمال
ALTER TABLE Students ADD CONSTRAINT PK_Students PRIMARY KEY (ID)
GO
--بررسی وضعیت مرتب سازی رکوردها
SELECT * FROM Students
GO
--بررسی فضای تخصیص داده شده به جدول
SP_SPACEUSED Students 
GO
--PK آنالیز ایندکس پس از اعمال 
SELECT 
	index_id,index_type_desc,
	index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('Students'),
	NULL,
	NULL,
	'DETAILED'
)
GO
--------------------------------------------------------------------
/*
Primary Key بررسی انواع حالت های مربوط به اضافه کردن 
باشد Not Null باید حتما PK فیلد یا فیلدهای 
*/
USE MyDB2017
GO
--PK ساخت جدول به همراه 
DROP TABLE IF EXISTS Persons 
GO
CREATE TABLE Persons 
(
    ID int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int,
    PRIMARY KEY (ID)
)
GO
--PK ساخت جدول به همراه 
DROP TABLE IF EXISTS Persons 
GO
CREATE TABLE Persons 
(
    ID int NOT NULL PRIMARY KEY,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int
)
GO
--PK ساخت جدول به همراه 
--کلید ترکیبی
DROP TABLE IF EXISTS Persons 
GO
CREATE TABLE Persons 
(
    ID int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int,
    CONSTRAINT PK_Person PRIMARY KEY (ID,LastName)
)
GO
--به جدول هایی که از قبل وجود دارندPK اضافه کردن 
ALTER TABLE Persons ADD CONSTRAINT PK_Person PRIMARY KEY (ID,LastName)
GO
ALTER TABLE Persons ADD PRIMARY KEY (ID)
GO
--Primary Key پاک کردن 
ALTER TABLE Persons DROP CONSTRAINT PK_Person
GO
