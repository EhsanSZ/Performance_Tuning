
USE DateDataBase
GO
SP_CONFIGURE 'clr enabled',1
RECONFIGURE WITH OVERRIDE
GO
--رجیتسر کردن اسمبلی در دیتابیس
CREATE ASSEMBLY PersianSQLFunctions FROM 'C:\DUMP\PersianSQLFunctions.dll'
GO
--CLR ارتباط با متد موجود در 
CREATE FUNCTION ToPersianDateTime
(
	@dt DateTime
)
RETURNS NVARCHAR(19)
AS EXTERNAL NAME  PersianSQLFunctions.UserDefinedFunctions.ToPersianDateTime
GO
--و استفاده از آنSQL Server ساخت فاکنشن در 
CREATE FUNCTION ToPersianDate
(
@dt DateTime
)
RETURNS NVARCHAR(10)
AS EXTERNAL NAME PersianSQLFunctions.UserDefinedFunctions.ToPersianDate
GO
SELECT dbo.ToPersianDate(GETDATE())
GO
