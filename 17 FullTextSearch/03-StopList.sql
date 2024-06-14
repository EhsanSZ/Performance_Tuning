
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
--Stop Listمشاهده
SELECT * FROM sys.fulltext_stoplists  
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
http://www.sqlservercentral.com/blogs/steve_jones/2013/01/21/full-text-search-thesaurus/
