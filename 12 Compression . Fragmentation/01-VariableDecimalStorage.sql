
USE master
GO
--ساخت بانک اطلاعاتی
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
--------------------------------------------------------------------
--Decimal,Numeric آشنایی با نوع داده
DECLARE @D DECIMAL(38,0)=12345678901234567890123456789012345678 --=1$ For IRAN
DECLARE @N NUMERIC(38,0)=12345678901234567890123456789012345678
SELECT @D
SELECT @N
SELECT DATALENGTH(@D)
SELECT DATALENGTH(@N)
GO
DECLARE @D DECIMAL(6,3)
SET @D=1223.121
GO
DECLARE @D DECIMAL(38,0)=123
DECLARE @N NUMERIC(38,0)=123
SELECT @D
SELECT @N
SELECT DATALENGTH(@D)
SELECT DATALENGTH(@N)
GO
--------------------------------------------------------------------
USE MyDB2017
GO
--بررسی جهت وجود جدول 
DROP TABLE IF EXISTS DecimalTest
DROP TABLE IF EXISTS NumericTest
GO
--ایجاد یک جدول تستی * به نوع فیلدهای جدول توجه کنید
CREATE TABLE DecimalTest
( 
	ID INT  PRIMARY KEY,
	DecimalCol DECIMAL(18, 0) NULL
) 
GO
--ایجاد یک جدول تستی * به نوع فیلدهای جدول توجه کنید
CREATE TABLE NumericTest
( 
	ID INT  PRIMARY KEY,
	NumericCol NUMERIC(18, 0) NULL
) 
GO
--درج تعدادی رکورد تستی در جداول
DECLARE @Counter SMALLINT =1
WHILE (@Counter <= 30000) 
BEGIN 
	IF (@Counter > 15000) 
		BEGIN
			INSERT INTO DecimalTest VALUES(@Counter, @Counter) 
			INSERT INTO NumericTest VALUES(@Counter, @Counter) 
		END
	ELSE 
		BEGIN
			INSERT INTO DecimalTest VALUES(@Counter, @Counter+100000000000000) 
			INSERT INTO NumericTest VALUES(@Counter, @Counter+100000000000000) 
		END
	SET @Counter+=1 
END
GO 
--بررسی حجم جداول
EXEC SP_SPACEUSED DecimalTest
EXEC SP_SPACEUSED NumericTest
GO
SELECT *,DATALENGTH(DecimalCol) FROM DecimalTest
GO
--تخمین فضای اشغال شده
--به ازای جدول فعال شود چقدر فضا اشغال خواهد شد VarDecimal در صورتیکه حالت
EXECUTE sp_estimated_rowsize_reduction_for_vardecimal 'DecimalTest' 
EXECUTE sp_estimated_rowsize_reduction_for_vardecimal 'NumericTest' 
GO
--به ازای بانک های اطلاعاتیVarDecimal Storage مشاهده تنظیمات 
EXECUTE sp_db_vardecimal_storage_format 
GO
-- استفاده کندVarDecimal Storage آیا بانک اطلاعاتی باید از تنظیمات 
EXECUTE sp_db_vardecimal_storage_format 'MyDB2017','OFF'
EXECUTE sp_db_vardecimal_storage_format 'MyDB2017','ON'
GO
-- به ازای جدول مورد نظر VarDecimal Storage اعمال تنظیمات 
EXEC sys.sp_tableoption 'DecimalTest', 'VarDecimal storage format',0
GO