
--گروه بندی بر روی جداولی که در آن تاریخ به صورت رشته ای و شمسی ذخیره شده است
USE master
GO
--بررسی بانک اطلاعاتی * در صورت وجود بانک اطلاعاتی حذف خواهد شد
IF DB_ID('DateDataBase')>0
BEGIN
	ALTER DATABASE DateDataBase SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DateDataBase
END
GO
--بازیابی بانک اطلاعاتی
RESTORE DATABASE DateDataBase FROM DISK='C:\dump\DateDataBase_Full.bak' 
WITH 
	MOVE'DateDataBase' TO 'C:\Dump\DateDataBase.mdf',
	MOVE'DateDataBase_log' TO 'C:\Dump\DateDataBase_log.ldf',
	STATS=1,REPLACE
GO
USE DateDataBase
GO
--بررسی تعداد رکوردهای موجود در جدول
SP_SPACEUSED OrderHeader --(Size 1.5GB)
GO
--بررسی فیلد تاریخ
SELECT TOP 100 * FROM OrderHeader
GO
SELECT * FROM DimDate
GO
---------------------------
--تاریخ شمسی به صورت رشته ای
GO
--استفاده از توابع رشته ای
SELECT 
	SUBSTRING(OrderDate_Shamsi_Str,1,4) AS [Year],
	SUBSTRING(OrderDate_Shamsi_Str,6,2) AS [Mount],
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
GROUP BY
	SUBSTRING(OrderDate_Shamsi_Str,1,4),
	SUBSTRING(OrderDate_Shamsi_Str,6,2) 
ORDER BY
	SUBSTRING(OrderDate_Shamsi_Str,1,4),
	SUBSTRING(OrderDate_Shamsi_Str,6,2)
GO
--DimDate استفاده از
SELECT 
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo,
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
INNER JOIN DimDate 
	ON DimDate.PersianStr=OrderHeader.OrderDate_Shamsi_Str
GROUP BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
ORDER BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
GO
---------------------------
--تاریخ شمسی به صورت عددی
GO
SELECT 
	OrderDate_Shamsi_Int,(OrderDate_Shamsi_Int/10000)*100,(OrderDate_Shamsi_Int /100),
	(OrderDate_Shamsi_Int /100)-(OrderDate_Shamsi_Int/10000)*100
FROM OrderHeader

--استفاده محاسبات عددی
SELECT 
	(OrderDate_Shamsi_Int/10000) AS [Year],
	(OrderDate_Shamsi_Int /100)-(OrderDate_Shamsi_Int/10000)*100 AS [Mount],
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
GROUP BY
	(OrderDate_Shamsi_Int/10000) ,
	(OrderDate_Shamsi_Int /100)-(OrderDate_Shamsi_Int/10000)*100 
ORDER BY
	(OrderDate_Shamsi_Int/10000) ,
	(OrderDate_Shamsi_Int /100)-(OrderDate_Shamsi_Int/10000)*100 
GO
--DimDate استفاده از
SELECT 
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo,
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
INNER JOIN DimDate 
	ON DimDate.PersianInt=OrderHeader.OrderDate_Shamsi_Int
GROUP BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
ORDER BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
GO
---------------------------
--Date تاریخ میلادی به صورت  
GO
--جهت تبدیل تاریخ میلادی به شمسیSQL Function استفاده از  
SELECT 
	SUBSTRING(dbo.Gregorian_Date_ToPersian(OrderDate_Miladi_Date),1,4) AS [Year],
	SUBSTRING(dbo.Gregorian_Date_ToPersian(OrderDate_Miladi_Date),6,2) AS [Mount],
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
GROUP BY
	SUBSTRING(dbo.Gregorian_Date_ToPersian(OrderDate_Miladi_Date),1,4),
	SUBSTRING(dbo.Gregorian_Date_ToPersian(OrderDate_Miladi_Date),6,2)
ORDER BY
	SUBSTRING(dbo.Gregorian_Date_ToPersian(OrderDate_Miladi_Date),1,4),
	SUBSTRING(dbo.Gregorian_Date_ToPersian(OrderDate_Miladi_Date),6,2)
GO
--DimDate استفاده از
SELECT 
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo,
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
INNER JOIN DimDate 
	ON DimDate.GregorianDate=OrderHeader.OrderDate_Miladi_Date
GROUP BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
ORDER BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
GO
---------------------------
--Date تاریخ میلادی به صورت  
GO
--جهت تبدیل تاریخ میلادی به شمسیCLR Function استفاده از  
SELECT 
	SUBSTRING(dbo.ToPersianDate(OrderDate_Miladi_Date),1,4) AS [Year],
	SUBSTRING(dbo.ToPersianDate(OrderDate_Miladi_Date),6,2) AS [Mount],
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
GROUP BY
	SUBSTRING(dbo.ToPersianDate(OrderDate_Miladi_Date),1,4),
	SUBSTRING(dbo.ToPersianDate(OrderDate_Miladi_Date),6,2)
ORDER BY
	SUBSTRING(dbo.ToPersianDate(OrderDate_Miladi_Date),1,4),
	SUBSTRING(dbo.ToPersianDate(OrderDate_Miladi_Date),6,2)
GO
--DimDate استفاده از
SELECT 
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo,
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
INNER JOIN DimDate 
	ON DimDate.GregorianDate=OrderHeader.OrderDate_Miladi_Date
GROUP BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
ORDER BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
GO
---------------------------
--تاریخ میلادی به صورت رشته ای
GO
--استفاده از توابع رشته ای
SELECT 
	SUBSTRING(dbo.Gregorian_Str_ToPersian(OrderDate_Miladi_Str),1,4) AS [Year],
	SUBSTRING(dbo.Gregorian_Str_ToPersian(OrderDate_Miladi_Str),6,2) AS [Mount],
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
GROUP BY
	SUBSTRING(dbo.Gregorian_Str_ToPersian(OrderDate_Miladi_Str),1,4),
	SUBSTRING(dbo.Gregorian_Str_ToPersian(OrderDate_Miladi_Str),6,2)
ORDER BY
	SUBSTRING(dbo.Gregorian_Str_ToPersian(OrderDate_Miladi_Str),1,4),
	SUBSTRING(dbo.Gregorian_Str_ToPersian(OrderDate_Miladi_Str),6,2)
GO
--DimDate استفاده از
SELECT 
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo,
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
INNER JOIN DimDate 
	ON DimDate.GregorianStr=OrderHeader.OrderDate_Miladi_Str
GROUP BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
ORDER BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
GO
---------------------------
--تاریخ میلادی به صورت عددی
GO
SELECT 
	OrderDate_Miladi_Int,(OrderDate_Miladi_Int/10000),(OrderDate_Miladi_Int/10000)*100,(OrderDate_Miladi_Int /100),
	(OrderDate_Miladi_Int /100)-(OrderDate_Miladi_Int/10000)*100
FROM OrderHeader

--استفاده محاسبات عددی
SELECT 
	(OrderDate_Miladi_Int/10000) AS [Year],
	(OrderDate_Miladi_Int /100)-(OrderDate_Miladi_Int/10000)*100 AS [Mount],
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
GROUP BY
	(OrderDate_Miladi_Int/10000) ,
	(OrderDate_Miladi_Int /100)-(OrderDate_Miladi_Int/10000)*100 
ORDER BY
	(OrderDate_Miladi_Int/10000) ,
	(OrderDate_Miladi_Int /100)-(OrderDate_Miladi_Int/10000)*100 
GO
--DimDate استفاده از
SELECT 
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo,
	COUNT(OrderHeaderID) AS Count_ID
FROM OrderHeader
INNER JOIN DimDate 
	ON DimDate.DateKey=OrderHeader.OrderDate_Miladi_Int
GROUP BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
ORDER BY
	DimDate.PersianYearInt,
	DimDate.PersianMonthNo
GO