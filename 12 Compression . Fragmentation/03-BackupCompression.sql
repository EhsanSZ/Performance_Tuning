
--Backup Compression
USE master
GO
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
--تهیه نسخه پشتیبان به شکل غیر فشرده
BACKUP DATABASE AdventureWorks2017 TO DISK='e:\dump\AW1.bak' 
	WITH STATS=1, FORMAT
GO
--تهیه نسخه پشتیبان به شکل فشرده
BACKUP DATABASE AdventureWorks2017 TO DISK='e:\dump\AW2.bak' 
	WITH STATS=1, FORMAT, COMPRESSION
GO
--تنظيم مقدار پيش فرض براي 
Exec sp_configure 'backup compression default',1
GO
RECONFIGURE
GO
--------------------------------------------------------------------
--SSMS  بررسی عملیات تهیه نسخه پشتیبان به شکل فشرده در
--Maintenance Plan استفاده از 
--------------------------------------------------------------------
