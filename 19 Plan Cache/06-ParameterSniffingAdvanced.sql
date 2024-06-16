
--ایجاد بانک اطلاعاتی جدید
USE master
GO
IF DB_ID('ParameterSniffingTest')>0
BEGIN
	ALTER DATABASE ParameterSniffingTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE ParameterSniffingTest
END
GO
CREATE DATABASE ParameterSniffingTest
GO
USE ParameterSniffingTest
GO
--------------------------------------------------------------------
USE ParameterSniffingTest
GO
--ایجاد جدول تستی
DROP TABLE IF EXISTS Customer
GO
CREATE TABLE Customer
(
  ID INT PRIMARY KEY IDENTITY(1,1),
  CustCode INT,
  CustName NVARCHAR(200),
  ContactNumber INT,
  Address NVARCHAR(255)
)
GO
--------------------------------------------------------------------
--ایجاد ایندکس
--------------------------------------------------------------------
--درج داده تستی در جدول
INSERT INTO Customer
	SELECT '101',N'مسعود طاهری','111111111',N'تهران -یوسف آباد'
	UNION ALL
	Select '102',N'فرید طاهری','222222222',N'تهران - یوسف آباد'
GO
SELECT * FROM Customer
GO
--------------------------------------------------------------------
--ساخت پروسیجر
USE ParameterSniffingTest
GO
CREATE OR ALTER PROCEDURE USP_GetCustomer
(
  @CustID INT,
  @CustName NVARCHAR(200)
)
AS
BEGIN
   SELECT 
     ID,
     CustCode,
     CustName,
     ContactNumber,
     Address
  FROM
     Customer
  WHERE ( CustCode = @custID OR CustName = @custName)
END
GO
--------------------------------------------------------------------
--اجرای پروسیجر
/*
Execution Plan بررسی 
Select Properties قسمت 
**
Parameter List توجه به قسمت 
Parameter Compiled Value
Parameter Run Value
*/
EXEC USP_GetCustomer '101','' 
GO
EXEC USP_GetCustomer 0,N'فرید طاهری'
GO
--------------------------------------------------------------------
SELECT
  t1.ObjectName,
  t1.plan_handle,
  t1.query_hash,
  t1.sql_text,
  pc.r.value('@Column', 'nvarchar(128)') AS Parameterlist,
  pc.r.value('@ParameterCompiledValue', 'nvarchar(128)') AS [compiled Value]
  ,pc.r.value('@ParameterRunValue', 'nvarchar(128)') AS [Run Value]
FROM
 (
   SELECT   
     OBJECT_NAME(est.objectid) ObjectName,
     DB_NAME(est.dbid) DBName,
     eqs.plan_handle,
     eqs.query_hash,
     SUBSTRING (est.text,eqs.statement_start_offset/2 +1,                                    
                 (CASE WHEN eqs.statement_end_offset = -1 
                       THEN LEN(CONVERT(NVARCHAR(MAX), est.text)) * 2 
                       ELSE eqs.statement_end_offset END - 
                       eqs.statement_start_offset)/2) AS sql_text,
     est.text as Whole_Batch,
     TRY_CONVERT(XML,SUBSTRING(etqp.query_plan,CHARINDEX('<ParameterList>',etqp.query_plan), CHARINDEX('</ParameterList>',etqp.query_plan) + LEN('</ParameterList>') - CHARINDEX('<ParameterList>',etqp.query_plan) )) parameters
   FROM sys.dm_exec_query_stats eqs
     CROSS APPLY sys.dm_exec_sql_text(eqs.sql_handle) est
     CROSS APPLY sys.dm_exec_text_query_plan(eqs.plan_handle, eqs.statement_start_offset, eqs.statement_end_offset) etqp
   WHERE est.ENCRYPTED <> 1
    -- AND OBJECT_NAME(est.objectid) = 'USP_GetCustomer'
 ) t1
OUTER APPLY t1.parameters.nodes('//ParameterList/ColumnReference') AS pc(r) 

/*
https://www.mssqltips.com/sqlservertip/4992/how-to-find-compiled-parameter-values-for-sql-server-cached-plans/
*/
