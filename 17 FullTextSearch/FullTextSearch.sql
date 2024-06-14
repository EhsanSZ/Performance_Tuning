
USE master
GO
IF DB_ID('FullTextDB')>0
	DROP DATABASE FullTextDB
GO
--بازیابی بانك اطلاعاتی مثال
RESTORE DATABASE FullTextDB FROM DISK='C:\Dump\FullTextDB.BAK' WITH
	MOVE 'FullTextDB' TO 'C:\Dump\FullTextDB.mdf',
	MOVE 'FullTextDB_log' TO 'C:\Dump\FullTextDB_log.LDF',REPLACE,STATS=1
GO
USE FullTextDB
GO
SELECT * FROM Persian
GO
SP_HELP 'Persian' --مشاهده ساختار جدول به فیلد رشته ای دقت كنید
GO
SELECT * FROM OtherLanguage --داده هایی شامل زبان های مختلف
GO
SP_HELP 'OtherLanguage' --مشاهده ساختار جدول به فیلد رشته ای دقت كنید
GO
SELECT * FROM SimpleTest
GO
SP_HELP 'SimpleTest' --مشاهده ساختار جدول به فیلد رشته ای دقت كنید
GO
--------------------------------------------------------
--پشتیبانی می کندFullText جاری ازInstance آیا 
SELECT SERVERPROPERTY('IsFullTextInstalled')
--------------------------------------------------------
--بدست آوردن لیست زبان هایی كه به صورت پیش فرض پشتیبانی می شوند
SELECT * FROM sys.fulltext_languages 
SELECT * FROM sys.fulltext_languages WHERE name='Arabic' --زبان عربی
SELECT * FROM sys.fulltext_languages WHERE name='Neutral' --زبان خنثی مناسب برای زبان فارسی
GO
--------------------------------------------------------
--Word Breaker
USE FullTextDB
GO
SELECT * FROM sys.fulltext_languages
GO
-- Parse 'data-base' in English
SELECT * FROM sys.dm_fts_parser('data-base', 1033, 0, 0)
GO
-- Parse 'data-base' in German
SELECT * FROM sys.dm_fts_parser('data-base', 1031, 0, 0)
GO
-- Parse 'data-base' in Russian --روسیه كمونیستی
SELECT * FROM sys.dm_fts_parser('data-base', 1049, 0, 0)
GO
-- Parse 'اطلاعاتی-بانك' in Neutral
SELECT * FROM sys.dm_fts_parser('data-base', 0, 0, 0)
---------
-- Parse 'اطلاعاتی-بانك' in English
SELECT * FROM sys.dm_fts_parser(N'اطلاعاتی-بانك', 1033, 0, 0)
GO
-- Parse 'اطلاعاتی-بانك' in Arabic
SELECT * FROM sys.dm_fts_parser(N'اطلاعاتی-بانك', 1025, 0, 0)
GO
-- Parse 'اطلاعاتی-بانك' in Neutral
SELECT * FROM sys.dm_fts_parser('بانك-اطلاعاتی', 0, 0, 0);
--------------------------------------------------------
--Stop List / Noise Word
--سیستمیStop Listمشاهده كلمه
SELECT * FROM sys.fulltext_system_stopwords 
GO
--های انگلیسیStop wordمشاهده كلمه
SELECT * FROM sys.fulltext_system_stopwords WHERE language_id=1033
GO
--های عربیStop wordمشاهده كلمه
SELECT * FROM sys.fulltext_system_stopwords WHERE language_id=1025
GO
--های خنثیStop wordمشاهده كلمه
SELECT * FROM sys.fulltext_system_stopwords WHERE language_id=0

--Stop Listایحاد
CREATE FULLTEXT STOPLIST StopList01 --semi-colon (;)
GO
--Stop Listایحاد
CREATE FULLTEXT STOPLIST StopList01;
GO
--Stop Listایحاد
CREATE FULLTEXT STOPLIST PersianStoplist AUTHORIZATION [dbo]; --مالك را مشخص می كند
GO
--Copying a full-text stoplist from the system full-text stoplist
CREATE FULLTEXT STOPLIST StopList02 FROM SYSTEM STOPLIST;
GO
--Copying a full-text stoplist from an existing full-text stoplist
CREATE FULLTEXT STOPLIST StopList03 FROM AdventureWorks.otherStoplist;
GO
--Stop Listمشاهده
SELECT * FROM sys.fulltext_stoplists  
GO
--Stop Listحذف
DROP FULLTEXT STOPLIST StopList01;
DROP FULLTEXT STOPLIST StopList02;
DROP FULLTEXT STOPLIST PersianStoplist;

GO
--Stop Listمشاهده
SELECT * FROM sys.fulltext_stoplists  
GO
--SSMSدر محیطStop Listایجاد
GO
CREATE FULLTEXT STOPLIST PersianStoplist;

--Stop Listاضافه كردن لغت به 
ALTER FULLTEXT STOPLIST PersianStoplist ADD 'Computer' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST PersianStoplist ADD 'hi' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST PersianStoplist ADD 'This' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST PersianStoplist ADD 'is' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST PersianStoplist ADD 'Computer' LANGUAGE 'Neutral'; --یكسان با اولی ولی زبان فرق دارد
ALTER FULLTEXT STOPLIST PersianStoplist ADD 'و' LANGUAGE 'Neutral';
ALTER FULLTEXT STOPLIST PersianStoplist ADD 'یا' LANGUAGE 'Neutral';
GO
--Stop Listمشاهده كلمه های موجود در 
SELECT * FROM sys.fulltext_stopwords 
GO
--Stop Listحذف كردن لغت از 
ALTER FULLTEXT STOPLIST PersianStoplist DROP 'hi' LANGUAGE 'English'; --حذف لغت از یك زبان خاص
SELECT * FROM sys.fulltext_stopwords 
GO
ALTER FULLTEXT STOPLIST PersianStoplist DROP ALL LANGUAGE 'English'; --حذف كلیه لغت های یك زبان خاص 
SELECT * FROM sys.fulltext_stopwords 
GO
ALTER FULLTEXT STOPLIST PersianStoplist DROP ALL; --Stop Listخالی كردن كلیه لغت های موجود در 
SELECT * FROM sys.fulltext_stopwords 
GO
--Stop Listاضافه كردن لغت به 
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'Computer' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'This' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'is' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'Computer' LANGUAGE 'Neutral'; --یكسان با اولی ولی زبان فرق دارد
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'و' LANGUAGE 'Neutral';
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'یا' LANGUAGE 'Neutral';
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'است' LANGUAGE 'Neutral';
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'تست' LANGUAGE 'Neutral';
ALTER FULLTEXT STOPLIST PersianStoplist ADD N'چند' LANGUAGE 'Neutral';
GO
--Stop Listمشاهده كلمه های موجود در 
SELECT * FROM sys.fulltext_stopwords 
GO
--SSMSدر محیطStop Wordایجاد
GO
--------------------------------------------------------
--File Groupایجاد
ALTER DATABASE FullTextDB ADD FILEGROUP FG_PersianData
GO
--های مربوط به بانك اطلاعاتیFile Groupمشاهده
SELECT * FROM sys.filegroups
GO
--اضافه شدن دیتا فایل به فایل گروه ها
ALTER DATABASE FullTextDB
	ADD FILE (NAME=PersianData,FILENAME='C:\Dump\PersianData.ndf') TO FILEGROUP FG_PersianData
GO
--مشاهده فایل های بانك اطلاعاتی
SELECT * FROM sys.database_files
GO
--بررسی وجود جدول و حذف آن
IF OBJECT_ID('Tmp_Persian')>0
	DROP TABLE Tmp_Persian
GO
--(FG_PersianData)جدیدFile GroupبهPersianانتفال جدول 
--ایجاد یك جدول جدید با همان ساختار قبلی در فایل گروه جدید
CREATE TABLE Tmp_Persian
(
	Code int NOT NULL IDENTITY (1, 1) ,
	Address nvarchar(80) COLLATE Persian_100_CI_AI NOT NULL,
	CONSTRAINT PK_Persian_Code  PRIMARY KEY CLUSTERED(Code) ,
)ON FG_PersianData
GO
--IDENTITYتنظیم برای عدم درج 
SET IDENTITY_INSERT Tmp_Persian ON
GO
--كپی كردن ركوردها از جدول قدیم به جدید
INSERT INTO Tmp_Persian (Code, [Address]) 
	SELECT Code, [Address] FROM Persian WHERE CODE BETWEEN 1 AND 1000
GO
SET IDENTITY_INSERT Tmp_Persian OFF
GO
--حذف جدول قدیم
DROP TABLE Persian
GO
--تغییر نام جدول جدید به جدول قدیم
EXECUTE sp_rename N'Tmp_Persian', N'Persian', 'OBJECT' 
GO
--نمایش اطلاعات موجود در جدول
SELECT * FROM Persian
GO
--نشان داده شود كه جدول متعلق به كدام فایل گروه می باشد
SP_HELP Persian
GO
--------------------------------------------------------
--Full Text Catalogایجاد
/*
CREATE FULLTEXT CATALOG catalog_name
     [ON FILEGROUP filegroup ]
     [IN PATH 'rootpath']--حذف شده است
     [WITH <catalog_option>]
     [AS DEFAULT]
     [AUTHORIZATION owner_name ]

<catalog_option>::=
     ACCENT_SENSITIVITY = {ON|OFF}
*/
--توجه كنید كه تقدم و تاخر  پارامترها مهم می باشد
CREATE FULLTEXT CATALOG PersianCatalog
	ON FILEGROUP FG_PersianData --نام فایل گروه
		WITH ACCENT_SENSITIVITY = OFF--تعیین حساسیت به لهجه
			AS DEFAULT--بعنوان كاتالوگ پیش فرض
				AUTHORIZATION dbo---مالك
GO
--Full Text Catalogمشاهده لیست
SELECT * FROM sys.fulltext_catalogs 
GO
--------------------------------------------------------
--Full Text Indexایجاد
--به اسلاید مراجعه شود
--ها ایجاد می شوندFull Text Catalogها در داخل Full Text Index
GO
--را جهت ایندكس كردن آماده كنیمAddress می خواهیم فیلد 
SP_HELP Persian
GO
--مشاهده كلید اصلی و یا یك كلید كه یونیك بودن ركوردها را مشخص می كند
SP_HELPINDEX Persian
GO
--از آنها پشتیبانی می كندFull Text Indexمشاهده لیست زبان هایی كه
--LICD,NAME
SELECT * FROM sys.fulltext_languages
GO
--استفاده می كندNeutralزبان فارسی به صورت پیش فرض از
SELECT * FROM sys.fulltext_languages WHERE name='Neutral' 
GO
--FULLTEXT INDEX ایجاد 
CREATE FULLTEXT INDEX
	ON Persian ([Address] LANGUAGE 'Neutral') --نام جدول،نام فیلد و زبانی كه می خواهیم ایندكس با الگوی آن انجام شود
		KEY INDEX PK_Persian --نام كلید یونیك
			ON PersianCatalog --FullText Catalogنام 
				WITH CHANGE_TRACKING = AUTO,--نحوه ردیابی تغییرات
					STOPLIST = PersianStoplist --StopListنام 
GO
--استخراج مقادیر موجود در ایندكس
SELECT * FROM sys.dm_fts_index_keywords(db_id('FullTextDB'), object_id('Persian'))
GO
--درج ركوردهای تستی در جدول
SET IDENTITY_INSERT Persian ON
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25911,N'تست')--Stop Word/Noise Word
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25912,N'گچ پژ')
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25913,N'جوجه')
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25914,N'سگ')
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25915,N'Computer')--Stop Word/Noise Word
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25916,N'FullText')
SET IDENTITY_INSERT Persian OFF
GO
SELECT * FROM Persian WHERE CODE BETWEEN 25911 AND 25916
GO
--استخراج مقادیر موجود در ایندكس
--با توجه به اینكه نحوه ردیابی تغییرات به شكل اتوماتیك است تغییرات به شكل خودكار اعمال می گردد
SELECT * FROM sys.dm_fts_index_keywords(db_id('FullTextDB'), object_id('Persian'))
	WHERE display_term IN (N'تست',N'گچ',N'پژ',N'جوجه',N'سگ',N'Computer',N'FullText')
--ها در ایندكس ظاهر نمی شوندNoise Wordدقت شود كه	
GO
--FULLTEXT INDEX ویرایش 
--ویرایش نحوه ردیابی تغییرات
ALTER FULLTEXT INDEX
	ON Persian --نام جدول
		SET CHANGE_TRACKING MANUAL; -- MANUAL | AUTO | OFF --نحوه ردیابی تغییرات
GO
--درج ركوردهای تستی در جدول
SET IDENTITY_INSERT Persian ON
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25930,N'Bolivia')
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25931,N'Gambia')
INSERT INTO Persian(CODE,[ADDRESS]) VALUES (25932,N'رسوم')
SET IDENTITY_INSERT Persian OFF
GO
SELECT * FROM Persian WHERE CODE BETWEEN 25930 AND 25932
GO
--استخراج مقادیر موجود در ایندكس
--با توجه به اینكه نحوه ردیابی تغییرات به شكل دستی است تغییرات به شكل خودكار اعمال نمی گردد
SELECT * FROM sys.dm_fts_index_keywords(db_id('FullTextDB'), object_id('Persian'))
	WHERE display_term IN (N'Bolivia',N'Gambia',N'رسوم')
GO
-- این حالت كلیه بر روی كلیه ركوردها عملیات درج حذف و ویرایش را ردیابی می كند 
ALTER FULLTEXT INDEX
	ON Persian --نام جدول
			START  UPDATE POPULATION;  --START {FULL|INCREMENTAL|UPDATE} POPULATION 
GO
--با توجه به اینكه اطلاعات موجود در ایندكس به روز آوری شد تغییرات نمایش داده می شوند
SELECT * FROM sys.dm_fts_index_keywords(db_id('FullTextDB'), object_id('Persian'))
	WHERE display_term IN (N'Bolivia',N'Gambia',N'رسوم')
GO
SET STATISTICS IO ON 
GO
SELECT * FROM Persian 
	WHERE [ADDRESS] LIKE N'%رسوم%'

SELECT * FROM Persian 
	WHERE CONTAINS(*,N'رسوم')

SELECT * FROM Persian 
	WHERE FREETEXT(*,N'')

SELECT *
FROM Persian
WHERE CONTAINS(*, ' "رسو*" ');

SELECT * FROM Persian 
	WHERE [ADDRESS] LIKE N'%رسو%'
--------------------------------------------------------
--بازسازی كلیه ایندكس های موجود در یك كاتالوگ
ALTER FULLTEXT CATALOG PersianCatalog REBUILD
GO
--سازمان دادن كلیه ایندكس های موجود در یك كاتالوگ 
ALTER FULLTEXT CATALOG PersianCatalog REORGANIZE
GO
--FULLTEXT INDEXحذف
DROP FULLTEXT INDEX ON SimpleTest
-----------------------------------------------
SELECT
	 c.name as CatalogName
	, t.name as TableName
	, idx.name as UniqueIndexName
	, case i.is_enabled when 1 then 'Enabled' else 'Not Enabled' end as IsEnabled
	, i.change_tracking_state_desc
	, sl.name as StoplistName
FROM sys.fulltext_indexes i
JOIN sys.fulltext_catalogs c
	ON i.fulltext_catalog_id = c.fulltext_catalog_id
JOIN sys.tables t
	ON i.object_id = t.object_id
JOIN sys.indexes idx
	ON i.unique_index_id = idx.index_id
	AND i.object_id = idx.object_id
LEFT JOIN sys.fulltext_stoplists sl
	ON sl.stoplist_id = i.stoplist_id;
GO
-----------------------------------------------
SELECT 
	[name] as CatalogName
	, FullTextCatalogProperty('PersianCatalog', 'IndexSize') AS IndexSizeMB
	, FullTextCatalogProperty('PersianCatalog', 'ItemCount') AS ItemCount
	, FullTextCatalogProperty('PersianCatalog', 'UniqueKeyCount') AS UniqueKeyCount
	, CASE FullTextCatalogProperty('PersianCatalog', 'PopulateStatus')
		WHEN 0 THEN 'Idle'
		WHEN 1 THEN 'Full population in progress'
		WHEN 2 THEN 'Paused'
		WHEN 3 THEN 'Throttled'
		WHEN 4 THEN 'Recovering'
		WHEN 5 THEN 'Shutdown'
		WHEN 6 THEN 'Incremental population in progress'
		WHEN 7 THEN 'Building index'
		WHEN 8 THEN 'Disk is full. Paused.'
		WHEN 9 THEN 'Change tracking'
		ELSE 'Error reading FullTextCatalogProperty PopulateStatus'
	  END AS PopulateStatus
	, CASE is_default
		WHEN 1 then 'Yes'
		ELSE 'No'
	  END AS IsDefaultCatalog
FROM sys.fulltext_catalogs ORDER BY [name];
GO
-----------------------------------------
--نحوه جستجو
SELECT * FROM Persian WHERE CONTAINS(*,N'حسين')--تعداد كم به علت اینكه اعداد جزء حروف اضافه هستند
SELECT * FROM Persian WHERE [Address] LIKE N'%حسين%'
GO
SET STATISTICS IO ON
GO
DBCC DROPCLEANBUFFERS
SELECT * FROM Persian WHERE CONTAINS(*,N'حسین')--تعداد كم به علت اینكه اعداد جزء حروف اضافه هستند
GO
DBCC DROPCLEANBUFFERS
SELECT * FROM Persian WHERE [Address] LIKE N'%حسین%'
GO
SET STATISTICS IO OFF
GO
--به محتویات ایندكس و تعداد ركوردها دقت شود
--dm_fts_index_keywords_by_documentبه این تابع دقت شود
--به شرط كوئری دقت شود
SELECT * FROM sys.dm_fts_index_keywords_by_document(db_id('FullTextDB'), object_id('Persian'))
	INNER JOIN Persian ON code=document_id
	WHERE display_term LIKE N'حسين' 
GO	
--به محتویات ایندكس و تعداد ركوردها دقت شود
--dm_fts_index_keywords_by_documentبه این تابع دقت شود
SELECT * FROM sys.dm_fts_index_keywords_by_document(db_id('FullTextDB'), object_id('Persian'))
	INNER JOIN Persian ON code=document_id
	WHERE display_term LIKE N'حسىن'
GO
SET STATISTICS IO ON
SELECT [ADDRESS] FROM Persian WHERE CONTAINS(*,'حسین')
SELECT [ADDRESS] FROM Persian WHERE FREETEXT(*,'%حسین%')
SELECT [ADDRESS] FROM Persian WHERE [ADDRESS] LIKE '%حسین%'



SELECT * FROM titles 
	WHERE CONTAINS(*,'Algorithm AND Security')

SELECT * FROM titles 
	WHERE CONTAINS(Notes,'FORMSOF(INFLECTIONAL, Describe)');



SELECT * FROM CONTAINSTABLE(Titles, Notes, 'ISABOUT (Read weight (.8), Computer weight (.4))') tmp
	ORDER BY RANK DESC

SELECT tmp.*, t.Notes FROM CONTAINSTABLE(Titles, Notes, 'ISABOUT (Read weight (.8), Computer weight (.4))') tmp
	JOIN Titles t
		ON tmp.[Key]=t.title_id 
			ORDER BY RANK DESC



