
/*
SQL Server بررسی نصب بودن سرویس های 
*/
USE master
GO
--FULLTEXTSERVICEPROPERTY استفاده از تابع
SELECT 
	CASE FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')
		WHEN 1 THEN 'Full-Text installed.' 
		ELSE 'Full-Text is NOT installed.' 
	END
GO
--DMV استفاده از 
SELECT 
	* 
FROM sys.dm_server_services
GO
/*
بررسی سرویس های در سطح ویندوز
*/
GO
--------------------------------------------------------------------
/*
به ازای بانک اطلاعاتی مورد نظر فعال استFullText Search آیا ویژگی 
*/
USE AdventureWorks2017
GO
SELECT 
	name,is_fulltext_enabled
FROM sys.databases
WHERE 
	database_id = DB_ID('AdventureWorks2017')
GO
exec sp_fulltext_database 'enable';
GO
--------------------------------------------------------------------
--بدست آوردن لیست زبان هایی كه به صورت پیش فرض پشتیبانی می شوند
SELECT * FROM sys.fulltext_languages 
SELECT * FROM sys.fulltext_languages WHERE name='Arabic' --زبان عربی
SELECT * FROM sys.fulltext_languages WHERE name='Neutral' --زبان خنثی مناسب برای زبان فارسی
GO 
