
--MISSING INDEX
USE AdventureWorks2017
GO
SP_HELPINDEX  'Person.Address'
GO
--SHOW EXECUTION PLANE & RUN
SET STATISTICS IO ON 
SELECT City, StateProvinceID, PostalCode
	FROM Person.Address
		WHERE StateProvinceID = 9;
GO
/*
DROP INDEX IX_Address_StateProvinceID ON Person.Address
DROP INDEX IX_Address_StateProvinceID1 ON Person.Address
DROP INDEX IX01 ON Person.Address
*/
--SHOW EXECUTION PLANE & RUN
SELECT SalesOrderDetailID, UnitPrice
	FROM AdventureWorks2017.Sales.SalesOrderDetail
		WHERE UnitPrice > 2000
GO
--DMV FOR MISSING INDEX
--هر سه با هم اجرا شود
SELECT * FROM sys.dm_db_missing_index_details
SELECT * FROM sys.dm_db_missing_index_group_stats --دقت كنيدUser_Seeks به ستون
SELECT * FROM sys.dm_db_missing_index_groups
GO
SELECT * FROM sys.dm_db_missing_index_columns(1) -- Index Handle
GO
---توليد دستورات مربوط به ايجاد ايندكس
SELECT mig.index_group_handle,mid.index_handle,migs.avg_total_user_cost AS AvgTotalUserCostThatCouldbeReduced,
       migs.avg_user_impact AS AvgPercentageBenefit,'CREATE INDEX missing_index_' + CONVERT (varchar, mig.index_group_handle)      
       + '_' + CONVERT (varchar, mid.index_handle)+ ' ON ' + mid.statement           
       + ' (' + ISNULL (mid.equality_columns,'')+ 
       CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns             
       IS NOT NULL THEN ',' ELSE ''        
       END               
       + ISNULL (mid.inequality_columns, '') + ')' + 
       ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement   
       FROM sys.dm_db_missing_index_groups mig 
       INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle 
       INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
GO