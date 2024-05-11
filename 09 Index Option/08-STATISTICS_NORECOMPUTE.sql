
/*
STATISTICS_NORECOMPUTE بررسی 

--كنترل محاسبه آمار خودكار ايندكس ها را مشخص مي كند
ON  : فاقد به روز رسانی خودکار
OFF : دارای به روز رسانی خودکار
Default :OFF
*/
USE tempdb
GO
--ساخت جدول تستی
DROP TABLE IF EXISTS T1
GO
CREATE TABLE T1
(
	F1 INT,
	F2 NVARCHAR(10)
)
GO
CREATE UNIQUE CLUSTERED INDEX IX1 ON T1(F1)
GO
--بررسی ایندکس های موجود درد جدول
SP_HELPINDEX T1
GO
--درج رکوردهای تستی در جدول
INSERT INTO T1 VALUES (1,'A')
INSERT INTO T1 VALUES (2,'B')
INSERT INTO T1 VALUES (3,'C')
GO
--مشاهده رکوردهای موجود در جدول
SELECT * FROM T1
GO
/*
STATISTICS بررسی وضعیت به روز رسانی خودکار 
دارای قابلیت به روز رسانی خودکار
*/
SELECT * FROM sys.stats WHERE object_id = OBJECT_ID('T1')
GO
--ایجاد مجدد ایندکس
CREATE UNIQUE CLUSTERED INDEX IX1 ON T1(F1)
	WITH (STATISTICS_NORECOMPUTE=ON,DROP_EXISTING = ON)
GO
/*
STATISTICS بررسی وضعیت به روز رسانی خودکار 
فاقد قابلیت به روز رسانی خودکار
*/
SELECT * FROM sys.stats WHERE object_id = OBJECT_ID('T1')
GO
