
USE master
GO
--بررسي جهت وجود بانك اطلاعاتي و حذف آن
IF DB_ID('PageAnatomy')>0
BEGIN
	ALTER DATABASE PageAnatomy SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE PageAnatomy
END
GO	
--ايجاد بانك اطلاعاتي
CREATE DATABASE PageAnatomy
GO
Use PageAnatomy
GO
--مشاهده فايل هاي مربوط به بانك اطلاعاتي
SP_HELPFILE
SELECT * FROM sys.database_files
GO
------------------------------------------------------------
--Create Table
------------------------------------------------------------
--بررسي جهت وجود جدول و بررسي آن
DROP TABLE IF EXISTS Test_Table
GO	
--ايجاد جدول
--به نوع داده جدول توجه کنید
CREATE TABLE Test_Table 
(
   FirstName CHAR(200),
   LastName  CHAR(300),
   Email     CHAR(200),   
)
GO
--درج تعدادي داده تستي در جدول
INSERT INTO Test_Table(FirstName,LastName,Email) VALUES 
	('Ehsan','Seyedzadeh','TestMail@yahoo.com'),
	('Ali','Seyedzadeh','Test1@yahoo.com'),
	('Amiir','Kharazi','Test2@yahoo.com'),
	('Hamid','Rahnama','Test3@yahoo.com'),
	('Mehran','Hejazi','Test4@yahoo.com'),
	('Hossein','Emami','Test5@yahoo.com')		
GO
--بودن جدول Heap بررسي  
SP_HELPINDEX Test_Table
GO
SELECT * FROM SYS.indexes 
	WHERE OBJECT_ID=OBJECT_ID('Test_Table')
GO
--بررسي حجم جدول
SP_SPACEUSED Test_Table
GO
--مشاهده ركوردهاي جدول
SELECT * FROM Test_Table
GO
-------------------------------
--های وابسته به یک جدولPage بدست آوردن 
--به هم مرتبط است Page, Extent با توجه به اینکه جدول هیپ است و شامل تعداد 
--صفحات وابسته به آن را استخراج کنیمIAM می توانیم با مراجعه به 
DBCC IND('PageAnatomy','Test_Table',-1) WITH NO_INFOMSGS;--همه ركوردها توجه iam_chanin_type به فيلد 
GO
--DBCC IND معادل 
SELECT 
	* 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('PageAnatomy'),OBJECT_ID('Test_Table'),
		NULL,NULL,'DETAILED'
	)
GO
-------------------------------
--ی قرار داردPageهر رکورد در چه 
SELECT 
	sys.fn_PhysLocFormatter (%%physloc%%) AS [Physical RID], 
	* 
FROM Test_Table;
GO
SELECT 
	* 
FROM Test_Table AS T 
	CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%) AS FPLC
ORDER BY 
	FPLC.file_id, FPLC.page_id, FPLC.slot_id
GO
-------------------------------
--Page مشاهده محتوای 
--DBCC PAGE بررسی تصویر برای دستور
DBCC TRACEON(3604);
DBCC PAGE('PageAnatomy',1,328,1)WITH NO_INFOMSGS;--به خروجي انتهاي اين جدول توجه كنيد
DBCC PAGE('PageAnatomy',1,78,3)WITH NO_INFOMSGS;
GO
/*
در هر دو دستور بالا بررسی شود Row Offset خروجی 
*/
-------------------------------
--بدست آوردن پیج های وابسته به یکی از جداول بانک اطلاعاتی مثال
USE AdventureWorks2017
GO
DBCC IND('AdventureWorks2017','Sales.SalesOrderHeader',-1) WITH NO_INFOMSGS;--همه ركوردها توجه iam_chanin_type به فيلد 
GO
--DBCC IND معادل 
SELECT 
	* 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks2017'),OBJECT_ID('Sales.SalesOrderHeader'),
		NULL,NULL,'DETAILED'
	)
GO

------------------------------------------------------------
--Show Page Information
------------------------------------------------------------
/*
BCC IND ( { 'dbname' | dbid }, { 'objname' | objid }, { nonclustered indid | 1 | 0 | -1 | -2 });
nonclustered indid = non-clustered Index ID 
1 = Clustered Index ID 
0 = Displays information in-row data pages and in-row IAM pages (from Heap) 
-1 = Displays information for all pages of all indexes including LOB (Large object binary) pages and row-overflow pages 
-2 = Displays information for all IAM pages
/*
1= data page
2= index page
3 and 4 = text pages
8 = GAM page
9 = SGAM page
10 = IAM page
11 = PFS page
*/
-------------------------------
dbcc page ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ]);Printopt:
0 - print just the page header
1 - page header plus per-row hex dumps and a dump of the page slot array 
2 - page header plus whole page hex dump
3 - page header plus detailed per-row interpretation
*/

--page corruption in sql server