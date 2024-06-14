
--Statistics مشاهده اجزاء
USE Northwind
GO
--بررسی جدول
SELECT * FROM [Order Details]
GO
--های یک جدولStats استخراج لیست
SP_HELPSTATS N'Order Details', 'ALL'
--Statistics مشاهده اجزاء
DBCC SHOW_STATISTICS (N'Order Details', ProductID)
GO
/*
Statistics بررسی قسمت های
1-Stat Header
2-Density Vector
3-Histogram (Data Distribution)
*/
-----------------------------------------------
--STAT_HEADER مشاهده قسمت 
DBCC SHOW_STATISTICS (N'Order Details', ProductID) WITH STAT_HEADER
GO
-----------------------------------------------
--DENSITY_VECTOR مشاهده قسمت 
DBCC SHOW_STATISTICS (N'Order Details', ProductID) WITH DENSITY_VECTOR
SELECT 1.00/COUNT(DISTINCT ProductID) FROM [Order Details]
/*
بالا Selectivity = کم Density 
پایین Selectivity = زیاد Density 
*/
GO
-----------------------------------------------
/*
حد بالای هر گام /ردیف از هیستوگرام است: RANGE_HI_KEY*
RANGE_HI_KEY تعداد سطرهای مساوی با ستون : EQ_ROWS*
تعداد سطرهای مقادیر ستون را در داخل محدوده گام بدون در نظر گرفتن حد بالا تخمین می زند: RANGE_ROWS*
تعداد سطرهای مقادیر غیر تکراری ستون را در داخل محدود گام بدون در نظر گرفتن حدبالا تخمین می زند : DISTINCT_RANGE_ROWS*
میانگین تعداد سطرها برای هر مقدار متمایزرا نشان می دهد به استثنا حد بالا: AVG_RANGE_ROWS*


RANGE_HI_KEY: مقدار سقف Step جاری.
RANGE_ROWS: نشان دهنده تعداد ردیف هایی است که مقداری بالاتر از مقدار سقف طبقه قبلی و کمتر از مقدار سقف طبقه فعلی دارند. (حالت اعشار یعنی نمونه برداری تصادفی)
EQ_ROWS: تعداد رکوردهایی که مقدار ستون اول آمار برابر با مقدار سقف طبقه جاری.
DISTINCT_RANGE_ROWS: تعداد مقادیر یونیک در استپ .
AVG_RANGE_ROWS: میانگین تعداد تکرار هر مقدار در این استپ .
 
AVG_RANGE_ROWS= RANGE_ROWS / DISTINCT_RANGE_ROWS
*/
--HISTOGRAM مشاهده قسمت 
DBCC SHOW_STATISTICS (N'Order Details', ProductID) WITH HISTOGRAM
--ProductID BETWEEN 51 AND 53
GO
--بررسی هیستوگرام
SELECT ProductID , COUNT (*)  AS Total FROM [Order Details]
	WHERE  ProductID BETWEEN 51 AND 53
		GROUP BY  ProductID
GO