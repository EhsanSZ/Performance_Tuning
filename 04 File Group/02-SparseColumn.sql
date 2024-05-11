
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
--ایجاد جدول تستی
DROP TABLE IF EXISTS TestTable 
GO
CREATE TABLE TestTable 
(
	C1 INT SPARSE,
	C2 INT SPARSE,
	C3 CHAR(100) SPARSE,
	C4 VARCHAR(100) SPARSE
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
Sparse Column مثال جاری با فعال بودن
(NULL,NULL,NULL,NULL)
Record 1 
Record Size = 9 Byte
---------
Record 2 
(1,2,'A','A')
Record Size = 137 Byte
*****************************************
Sparse Column مثال قبل بدون فعال بودن
(NULL,NULL,NULL,NULL)
Record 1 
Record Size = 115 Byte
---------
Record 2 
(1,2,'A','A')
Record Size = 120 Byte
*/
--------------------------------------------------------------------
--برای جداول با حجم داده زیاد برای نال Sparse Column استفاده از 
USE MyDB2017
GO
DROP TABLE IF EXISTS STUDENT_INFO_01
DROP TABLE IF EXISTS STUDENT_INFO_02
GO
-- Sparse Columnsایجاد جدول بدون 
CREATE TABLE STUDENT_INFO_01
(
	ID    INT IDENTITY,
	F_NAME NVARCHAR(50),
	L_NAME NVARCHAR(50),
	D1 CHAR(100),
	D2 CHAR(100),
	D3 CHAR(100),
	D4 CHAR(100),
	D5 CHAR(100),
	D6 CHAR(100),
	D7 CHAR(100),
	D8 CHAR(100),
	D9 CHAR(100),
	D10 CHAR(100)
)
GO
-- Sparse Columnsایجاد جدول با 
CREATE TABLE STUDENT_INFO_02
(
	ID    INT IDENTITY,
	F_NAME NVARCHAR(50),
	L_NAME NVARCHAR(50),
	D1 CHAR(100) SPARSE,
	D2 CHAR(100) SPARSE,
	D3 CHAR(100) SPARSE,
	D4 CHAR(100) SPARSE,
	D5 CHAR(100) SPARSE,
	D6 CHAR(100) SPARSE,
	D7 CHAR(100) SPARSE,
	D8 CHAR(100) SPARSE,
	D9 CHAR(100) SPARSE,
	D10 CHAR(100) SPARSE
)
GO
-- Sparse Columns جدول بدون 
--درج اطلاعات در جدول اول
INSERT INTO STUDENT_INFO_01 (F_NAME,L_NAME,D2,D3,D4) VALUES ('A','A','D12E5','21E1','Q10A')
INSERT INTO STUDENT_INFO_01 (F_NAME,L_NAME,D2,D3,D4) VALUES ('B','B','1T2U5','41O1','R1D0')
INSERT INTO STUDENT_INFO_01 (F_NAME,L_NAME,D2,D3,D4) VALUES ('C','C','1U2O5','7P11','W0F5')
GO 1000
-------------------------------
-- Sparse Columns جدول با 
--درج اطلاعات در جدول دوم
INSERT INTO STUDENT_INFO_02 (F_NAME,L_NAME,D2,D3,D4) VALUES ('A','A','D12E5','21E1','Q10A')
INSERT INTO STUDENT_INFO_02 (F_NAME,L_NAME,D2,D3,D4) VALUES ('B','B','1T2U5','41O1','R1D0')
INSERT INTO STUDENT_INFO_02 (F_NAME,L_NAME,D2,D3,D4) VALUES ('C','C','1U2O5','7P11','W0F5')
GO 1000
--به روز رسانی برخی ستون ها
UPDATE STUDENT_INFO_01 SET 
	D5='XXXX',D6='XXXX',D7='XXXX',
	D8='XXXX',D9='XXXX',D10='XXXX'
WHERE ID%45=1
GO
UPDATE STUDENT_INFO_02 SET 
	D5='XXXX',D6='XXXX',D7='XXXX',
	D8='XXXX',D9='XXXX',D10='XXXX'
WHERE ID%45=1
-------------------------------
--مشاهده رکوردهای درج شده
SELECT * FROM STUDENT_INFO_01
SELECT * FROM STUDENT_INFO_02
GO
-------------------------------
--مشاهده حجم تخصیص داده شده به جداول
SP_SPACEUSED STUDENT_INFO_01
GO
SP_SPACEUSED STUDENT_INFO_02
GO
--چک کردن اندازه
-- Cheking the Size of Rows
SELECT [avg_record_size_in_bytes] FROM
	 sys.dm_db_index_physical_stats (DB_ID('MyDB2017'), OBJECT_ID ('STUDENT_INFO_01'), NULL, NULL, 'DETAILED')
GO
SELECT [avg_record_size_in_bytes] FROM
	 sys.dm_db_index_physical_stats (DB_ID('MyDB2017'), OBJECT_ID ('STUDENT_INFO_02'), NULL, NULL, 'DETAILED')
GO
--------------------------------------------------------------------
--Column Sets استفاده از 
--تشخیص ستوان هایی که دارای مقدار هستند
USE MyDB2017
GO
DROP TABLE IF EXISTS STUDENT_INFO
GO
CREATE TABLE STUDENT_INFO
(
	ID    INT IDENTITY,
	F_NAME NVARCHAR(50),
	L_NAME NVARCHAR(50),
	D1 INT SPARSE,
	D2 INT SPARSE,
	D3 INT SPARSE,
	DetailSet XML COLUMN_SET FOR ALL_SPARSE_COLUMNS 
)
GO
INSERT INTO STUDENT_INFO (F_NAME,L_NAME,D1,D2,D3) VALUES
	('Ehsan','Seyedzadeh',1,2,3),
	('Amir','Kharazi',1,NULL,3),
	('Ali','Seyedzadeh',1,NULL,NULL),
	('Hamid','Rahnama',1,2,NULL)
GO
SELECT * FROM STUDENT_INFO
GO
SELECT 
	ID,
	F_NAME,
	L_NAME,
	D1,D2,D3,
	DetailSet
FROM STUDENT_INFO

GO