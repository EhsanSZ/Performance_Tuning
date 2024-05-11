
--Filestream کردن رکوردها در Update بررسی عملیات 
USE MyDB2017
GO
SELECT *,CAST(Content AS VARCHAR(MAX)) FROM TestTable
GO
UPDATE TestTable SET 
	Content= CAST('Hello Ehsan!' AS VARBINARY(MAX))
WHERE ID=1
GO
SELECT *,CAST(Content AS VARCHAR(MAX)) FROM TestTable
GO
UPDATE TestTable SET 
	Content= NULL
WHERE ID=1
GO
SELECT *,CAST(Content AS VARCHAR(MAX)) FROM TestTable
GO
UPDATE TestTable SET 
	Content= 0x
WHERE ID=1
GO
SELECT *,CAST(Content AS VARCHAR(MAX)) FROM TestTable
GO
--------------------------------------------------------------------
USE MyDB2017
GO
--Filestream کردن رکوردها در Delete بررسی عملیات 
INSERT INTO TestTable(Title,Content) VALUES
	('Ehsan Seyedzadeh',CAST(REPLICATE('Ehsan Seyedzadeh*',10) AS VARBINARY(MAX))),
	('Ali Seyedzadeh',CAST(REPLICATE('Ali Seyedzadeh*',10) AS VARBINARY(MAX))),
	('Hamid Rahnam',CAST(REPLICATE('Hamid Rahnama*',10) AS VARBINARY(MAX)))
GO
SELECT *,CAST(Content AS VARCHAR(MAX)) FROM TestTable
GO
DELETE FROM TestTable WHERE ID=1
GO
--فايل ركوردهاي مورد نظر به زودي از ديسك پاك نمي شود
CHECKPOINT 
GO
--اجبار برای پاک کردن فایل های فایل استریم
EXEC sp_filestream_force_garbage_collection @dbname = N'MyDB2017'
GO
EXEC sp_filestream_force_garbage_collection  
	@dbname =   'MyDB2017'  , @filename = 'MyDB2017_FSG' 
GO
--Tuncate امکان استفاده از دستور 
TRUNCATE TABLE TestTable
GO
--------------------------------------------------------------------
--بررسی پاک کردن دستی خود فایل ها
USE MyDB2017
GO
--Filestream کردن رکوردها در Delete بررسی عملیات 
INSERT INTO TestTable(Title,Content) VALUES
	('Ehsan Seyedzadeh',CAST(REPLICATE('Ehsan Seyedzadeh*',10) AS VARBINARY(MAX))),
	('Ali Seyedzadeh',CAST(REPLICATE('Ali Seyedzadeh*',10) AS VARBINARY(MAX))),
	('Amir Kharazi',CAST(REPLICATE('Amir Kharazi*',10) AS VARBINARY(MAX)))
GO
SELECT *,CAST(Content AS VARCHAR(MAX)) FROM TestTable
GO
--اسم فایلی کپی شود و پس از آن پاک شود
DBCC CHECKDB
GO
--بررسی روش رفع مشکل
GO