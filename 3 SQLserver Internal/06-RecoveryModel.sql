
--Recovery Model بررسی 
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
--ایجاد یک جدول جدید
DROP TABLE IF EXISTS TestTable
GO
CREATE TABLE TestTable
(
	C1 INT IDENTITY PRIMARY KEY,
	C2 NVARCHAR(10),
	C3 NVARCHAR(10)
)
GO
INSERT TestTable(C2,C3) VALUES (N'T1',N'T11')
GO
-------------------------------
--بانک اطلاعاتی جاری و سایر بانک های اطلاعاتیRecovery Model مشاهده 
--بانک های اطلاعاتی سیستمیRecovery Model مشاهده 
SELECT 
	database_id,name,recovery_model_desc 
FROM SYS.databases
WHERE name='MyDB2017'
GO
-------------------------------
--چند کوئری مهم و کاربردی
GO
--Log File مشاهده وضعیت استفاده از 
DBCC SQLPERF('LOGSPACE')
GO
USE MyDB2017
GO
--مشاهده ظرفیت فایل های بانک اطلاعاتی
SP_HELPFILE
GO
SELECT 
	name,
	type_desc,
	physical_name,
	CAST((size*8.0/1024) AS DECIMAL(18,2))AS Size_MB,
	max_size
FROM SYS.database_files
GO
--log_reuse_wait مشاهده وضعیت 
SELECT 
	name ,
	recovery_model_desc ,
	log_reuse_wait_desc
FROM	sys.databases
WHERE	name = 'MyDB2017'
GO
