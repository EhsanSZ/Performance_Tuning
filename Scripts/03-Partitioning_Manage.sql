-------
--مدیریت پارتیشن 
--Merge : حذف یک نقطه مرزی
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE MyDB2017
GO
--ایجاد فایل گروه های مربوط به بانک اطلاعاتی
ALTER DATABASE MyDB2017 ADD FILEGROUP One
ALTER DATABASE MyDB2017 ADD FILEGROUP Two
ALTER DATABASE MyDB2017 ADD FILEGROUP Three
ALTER DATABASE MyDB2017 ADD FILEGROUP Four
GO
--تخصیص دیتا فایل به هر کدام از فایل گروه ها
ALTER DATABASE MyDB2017 ADD FILE
	(NAME = N'One_File01',FILENAME = N'C:\Dump\One_File01.ndf') TO FILEGROUP One
GO
ALTER DATABASE MyDB2017 ADD FILE
	(NAME = N'Two_File01',FILENAME = N'C:\Dump\Two_File01.ndf') TO FILEGROUP Two
GO
ALTER DATABASE MyDB2017 ADD FILE
	(NAME = N'Three_File01',FILENAME = N'C:\Dump\Three_File01.ndf') TO FILEGROUP Three
GO
ALTER DATABASE MyDB2017 ADD FILE
	(NAME = N'Four_File01',FILENAME = N'C:\Dump\Four_File01.ndf') TO FILEGROUP Four
GO
-----------------------------
USE MyDB2017
GO
--ایجاد پارتیشن فانکشن
CREATE PARTITION FUNCTION pfR(INT)
	AS RANGE RIGHT FOR VALUES (100,200,300)
GO
--ایجاد پارتیشن اسکیم
CREATE PARTITION SCHEME psR AS PARTITION pfR TO
	(One,Two,Three,Four)
GO
--ایجاد جدول پارتیشن شده
CREATE TABLE R (ID INT) ON psR(ID);
GO
INSERT INTO R VALUES (NULL)
INSERT INTO R VALUES (-1)
INSERT INTO R VALUES (0)
INSERT INTO R VALUES (1)
INSERT INTO R VALUES (100)
INSERT INTO R VALUES (101)
INSERT INTO R VALUES (200)
INSERT INTO R VALUES (201)
INSERT INTO R VALUES (300)
INSERT INTO R VALUES (301)
INSERT INTO R VALUES (1001)
GO
SELECT * FROM R
-----------------------------
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--مدیریت پارتیشن 
--Merge : حذف یک نقطه مرزی
ALTER PARTITION FUNCTION pfR() MERGE RANGE(200)
GO
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
--Partition Function,Partition Scheme بررسی سورس 
/*
CREATE PARTITION FUNCTION pfR(int) 
	AS RANGE RIGHT FOR VALUES (100, 300)
GO
CREATE PARTITION SCHEME psR 
	AS PARTITION pfR TO ([One], [Two], [Four])
GO
*/
DROP TABLE R 
DROP PARTITION SCHEME psR
DROP PARTITION FUNCTION pfR
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--مدیریت پارتیشن 
--Split : اضافه کردن یک نقطه مرزی
USE MyDB2017
GO
CREATE PARTITION FUNCTION pfR(int) 
	AS RANGE RIGHT FOR VALUES (100, 300)
GO
CREATE PARTITION SCHEME psR 
	AS PARTITION pfR TO ([One], [Two], [Four])
GO
CREATE TABLE R (ID INT) ON psR(ID);
GO
INSERT INTO R VALUES (NULL)
INSERT INTO R VALUES (-1)
INSERT INTO R VALUES (0)
INSERT INTO R VALUES (1)
INSERT INTO R VALUES (100)
INSERT INTO R VALUES (101)
INSERT INTO R VALUES (200)
INSERT INTO R VALUES (201)
INSERT INTO R VALUES (300)
INSERT INTO R VALUES (301)
INSERT INTO R VALUES (1001)
GO
SELECT * FROM R
GO
-----------------------------
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
ALTER PARTITION SCHEME psR NEXT USED [Three]  --Step1
ALTER PARTITION FUNCTION pfR() SPLIT RANGE(200) --Step2
GO
/*
--Step 1
CREATE PARTITION SCHEME [psR] AS PARTITION [pfR] TO ([One], [Two], [Four], [Three])
CREATE PARTITION FUNCTION [pfR](int) AS RANGE RIGHT FOR VALUES (100, 300)
GO
--Step2
CREATE PARTITION SCHEME [psR] AS PARTITION [pfR] TO ([One], [Two], [Three], [Four])
CREATE PARTITION FUNCTION [pfR](int) AS RANGE RIGHT FOR VALUES (100, 200, 300)
GO
*/
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
DROP TABLE R 
DROP PARTITION SCHEME psR
DROP PARTITION FUNCTION pfR
GO
/*
--Right
ALTER PARTITION SCHEME psR NEXT USED [Three]
ALTER PARTITION FUNCTION pfR() SPLIT RANGE(200)
GO
--Left
ALTER PARTITION SCHEME psL NEXT USED [Two]
ALTER PARTITION FUNCTION pfL() SPLIT RANGE(200)
GO
*/
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
/*
--1 : Switch from Non-Partitioned to Non-Partitioned
انتقال داده های یک جدول به جدولی دیگر
هر دو جدول به صورت غیر پارتیشن شده هستند
*/
GO
--بررسی جهت وجود جدول و حذف آن
DROP TABLE IF EXISTS S1
DROP TABLE IF EXISTS S1
GO
--ایجاد جدول تستی
CREATE TABLE S1
(
	C1 INT PRIMARY KEY,
	C2 NVARCHAR(100)
)
GO
--ایجاد جدول تستی
CREATE TABLE S2
(
	C1 INT PRIMARY KEY,
	C2 NVARCHAR(100)
)
GO
--درج رکورد تستی در جدول
INSERT INTO S1 (C1,C2) VALUES 
	(1,'A'),
	(2,'B'),
	(3,'C')
GO
--مشاهده رکوردهای تستی
SELECT * FROM S1
SELECT * FROM S2
GO
--انتقال دیتا از یک جدول له جدول دیگر با دستور سوئیچ
--ALTER TABLE Source SWITCH TO Target
ALTER TABLE S1 SWITCH TO S2
GO
--مشاهده رکوردهای تستی
SELECT * FROM S1
SELECT * FROM S2
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--مدیریت پارتیشن 
--Switch : جابجایی پارتیشن بین جداول
USE MyDB2017
GO
CREATE PARTITION FUNCTION pfR(INT)
	AS RANGE RIGHT FOR VALUES (100,200,300)
GO
CREATE PARTITION SCHEME psR AS PARTITION pfR TO
	(One,Two,Three,Four)
GO
CREATE TABLE R (ID INT) ON psR(ID);
GO
INSERT INTO R VALUES (NULL)
INSERT INTO R VALUES (-1)
INSERT INTO R VALUES (0)
INSERT INTO R VALUES (1)
INSERT INTO R VALUES (100)
INSERT INTO R VALUES (101)
INSERT INTO R VALUES (200)
INSERT INTO R VALUES (201)
INSERT INTO R VALUES (300)
INSERT INTO R VALUES (301)
INSERT INTO R VALUES (1001)
GO
SELECT * FROM R
GO
-----------------------------
DROP TABLE IF EXISTS R2 
CREATE TABLE R2 (ID INT) ON Two
GO
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
ALTER TABLE R SWITCH PARTITION 2 TO R2
GO
/*
CREATE PARTITION SCHEME psR AS PARTITION [pfR] TO (One, Two,Three,Four)
CREATE PARTITION FUNCTION pfR(int) AS RANGE RIGHT FOR VALUES (100, 200, 300)
GO
*/
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
SELECT * FROM R
SELECT * FROM R2
GO
--حالا برعکس این کار را انجام دهید
--بررسی پیام
ALTER TABLE R2 SWITCH TO R PARTITION 2
GO
ALTER TABLE R2 ADD CONSTRAINT Check1
	CHECK (ID>=100 AND ID< 200 AND ID IS NOT NULL)
GO
ALTER TABLE R2 SWITCH TO R PARTITION 2
GO
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
SELECT * FROM R
SELECT * FROM R2
GO
DROP TABLE IF EXISTS R
DROP PARTITION SCHEME psR
DROP PARTITION FUNCTION pfR
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--جابجایی مابین دو پارتیشن
USE MyDB2017
GO
DROP TABLE IF EXISTS R1
DROP TABLE IF EXISTS R2
DROP PARTITION SCHEME psR
DROP PARTITION FUNCTION pfR
GO
CREATE PARTITION FUNCTION pfR(INT)
	AS RANGE RIGHT FOR VALUES (100,200,300)
GO
CREATE PARTITION SCHEME psR AS PARTITION pfR TO
	(One,Two,Three,Four)
GO
CREATE TABLE R1 (ID INT) ON psR(ID);
CREATE TABLE R2 (ID INT) ON psR(ID);
GO
INSERT INTO R1 VALUES (NULL)
INSERT INTO R1 VALUES (-1)
INSERT INTO R1 VALUES (0)
INSERT INTO R1 VALUES (1)
INSERT INTO R1 VALUES (100)
INSERT INTO R1 VALUES (101)
INSERT INTO R1 VALUES (200)
INSERT INTO R1 VALUES (201)
INSERT INTO R1 VALUES (300)
INSERT INTO R1 VALUES (301)
INSERT INTO R1 VALUES (1001)
GO
INSERT INTO R2 VALUES (100)
INSERT INTO R2 VALUES (101)
INSERT INTO R2 VALUES (200)
INSERT INTO R2 VALUES (201)
INSERT INTO R2 VALUES (300)
INSERT INTO R2 VALUES (301)
INSERT INTO R2 VALUES (1001)
GO
SELECT * FROM R1
SELECT * FROM R2
GO
--استخراج تعداد داده هاي موجود در هر پارتيشن به همراه حداقل و حداكثر مقدار در هر پارتيشن
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R1
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
SELECT 
	$PARTITION.pfR(ID) AS [Partition Number]
	, MIN(ID) AS [Min ID]
	, MAX(ID) AS [Max ID]
	, COUNT(ID) AS [Rows In Partition]
FROM R2
GROUP BY 
	$PARTITION.pfR(ID)
ORDER BY 
	[Partition Number]
GO
ALTER TABLE R1 SWITCH PARTITION 1 TO R2 PARTITION 1
GO
