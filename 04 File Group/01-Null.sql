
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
-------------------------------
Use MyDB2017
GO
DECLARE @X1 INT=NULL
DECLARE @X2 INT=0
DECLARE @X3 VARCHAR(10)=NULL
DECLARE @X4 VARCHAR(10)=''
DECLARE @X5 VARCHAR(10)='A'

SELECT @X1,DATALENGTH(@X1)
SELECT @X2,DATALENGTH(@X2)
SELECT @X3,DATALENGTH(@X3)
SELECT @X4,DATALENGTH(@X4)
SELECT @X5,DATALENGTH(@X5)

GO
-------------------------------
--ایجاد جدول تستی
DROP TABLE IF EXISTS TestTable 
GO
CREATE TABLE TestTable 
(
	C1 INT,
	C2 INT,
	C3 CHAR(100),
	C4 VARCHAR(100)
)
GO
--درج تعدادی رکورد تستی در جدول 
INSERT INTO TestTable (C1,C2,C3,C4) VALUES 
	(NULL,NULL,NULL,NULL),
	(1,2,'A','A')
GO
--مشاهده رکوردهای درج شده
SELECT * FROM TestTable
GO
-------------------------------
--های تخصیص داده شده به جدولPage مشاهده 
--همه ركوردها توجه iam_chanin_type به فيلد 
DBCC IND('MyDB2017','TestTable',-1) WITH NO_INFOMSGS;
GO
SELECT 
	allocated_page_page_id,
	page_type_desc,
	allocated_page_iam_page_id,
	extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('MyDB2017'),OBJECT_ID('TestTable'),
		NULL,NULL,'DETAILED'
	)
GO
-------------------------------
--Page مشاهده محتوای 
--Record Size بررسی 
DBCC TRACEON (3604)
GO
DBCC PAGE ('MyDB2017', 1, 328, 3)
GO
/* 
(NULL,NULL,NULL,NULL)
Record 1 
Record Size = 115 Byte
---------
Record 2 
(1,2,'A','A')
Record Size = 120 Byte
*/

