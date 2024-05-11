
--SQL Server مشاهده قسمت های مختلف حافظه در 
DBCC MemoryStatus
GO
---------------------
USE master
GO
--بررسي جهت وجود بانك اطلاعاتي و حذف آن
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
---------------------
--Create Table
--بررسي جهت وجود جدول و بررسي آن
IF OBJECT_ID('Test_Table')>0
	DROP TABLE Test_Table
GO	
--ايجاد جدول
CREATE TABLE Test_Table 
(
   FirstName CHAR(1000),
   LastName  CHAR(1000),
   Email     CHAR(1000),   
)
GO
--درج تعدادي داده تستي در جدول
INSERT INTO Test_Table(FirstName,LastName,Email) VALUES 
	('Ehsan','Seyedzadeh','TestMail@gmail.com')
GO 1000
--مشاهده ركوردهاي جدول
SELECT * FROM Test_Table
GO
---------------------
--به ازای هر بانک اطلاعاتی Buffer Pool مشاهده فضای تخصیص داده شده در 
;WITH src AS
(
	SELECT
		database_id, db_buffer_pages = COUNT_BIG(*)
		FROM sys.dm_os_buffer_descriptors
		GROUP BY database_id
)
SELECT
	[db_name] = CASE [database_id] WHEN 32767
		THEN 'Resource DB'
		ELSE DB_NAME([database_id]) END,
	db_buffer_pages,
	db_buffer_MB = CAST(db_buffer_pages / 128.0 AS DECIMAL(6,2))
FROM src
ORDER BY db_buffer_MB DESC;
GO


