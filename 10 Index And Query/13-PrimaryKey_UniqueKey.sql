
USE tempdb
GO
--بررسی وجود جدول 
DROP TABLE IF EXISTS Students
GO
--ایجاد جدول تستی
CREATE TABLE Students
(
	ID INT PRIMARY KEY,
	NationalCode BIGINT UNIQUE,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(70)
)
GO
--های موجود در جدولConstraint مشاهده 
SP_HELPCONSTRAINT Students
GO
--مشاهده ایندکس های موجود در جدول
SP_HELPINDEX Students
GO
SET STATISTICS IO ON 
GO
INSERT INTO  Students(ID,NationalCode,FirstName,LastName) 
	VALUES (NULL,'1234567890',N'مسعود',N'طاهری')
GO
INSERT INTO  Students(ID,NationalCode,FirstName,LastName) 
	VALUES (1,NULL,N'مسعود',N'طاهری')
GO
INSERT INTO  Students(ID,NationalCode,FirstName,LastName) 
	VALUES (2,NULL,N'فرید',N'طاهری')
GO
INSERT INTO  Students(ID,NationalCode,FirstName,LastName) 
	VALUES (1,NULL,N'مجید',N'طاهری')
GO
--------------------------------------------------------------------
USE tempdb
GO
--بررسی وجود جدول 
DROP TABLE IF EXISTS Students1
GO
--Unique Constraint ایجاد جدول تستی دارای
CREATE TABLE Students1
(
	ID INT PRIMARY KEY,
	NationalCode BIGINT UNIQUE,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(70)
)
GO
DROP TABLE IF EXISTS Students2
GO
--Unique Constraint ایجاد جدول تستی فاقد
CREATE TABLE Students2
(
	ID INT PRIMARY KEY,
	NationalCode BIGINT ,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(70)
)
GO
--ساخت ایندکس
CREATE UNIQUE NONCLUSTERED INDEX IX_NationalCode ON Students2(NationalCode)
GO
--Actual Execution Plan نمایش 
GO
SET STATISTICS IO ON 
INSERT INTO  Students1(ID,NationalCode,FirstName,LastName) 
	VALUES (2,1,N'فرید',N'طاهری')
INSERT INTO  Students2(ID,NationalCode,FirstName,LastName) 
	VALUES (2,1,N'فرید',N'طاهری')
SET STATISTICS IO OFF