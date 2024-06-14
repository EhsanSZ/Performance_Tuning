
--Word Breaker
USE NikAmoozDB2017
GO
--از آنها پشتیبانی می کند Full-Text Search استخراج زبان هایی که 
SELECT * FROM sys.fulltext_languages ORDER BY lcid
GO
-- Parse 'data-base' in English
SELECT * FROM sys.dm_fts_parser('data-base', 1033, 0, 0)
GO
-- Parse 'data-base' in German
SELECT * FROM sys.dm_fts_parser('data-base', 1031, 0, 0)
GO
-- Parse 'data-base' in Russian --روسیه 
SELECT * FROM sys.dm_fts_parser('data-base', 1049, 0, 0)
GO
-- Parse 'اطلاعاتی-بانک' in Neutral
SELECT * FROM sys.dm_fts_parser('data-base', 0, 0, 0)
GO
-- Parse 'اطلاعاتی-بانک' in English
SELECT * FROM sys.dm_fts_parser(N'اطلاعاتی-بانک', 1033, 0, 0)
GO
-- Parse 'اطلاعاتی-بانک' in Arabic
SELECT * FROM sys.dm_fts_parser(N'اطلاعاتی-بانک', 1025, 0, 0)
GO
-- Parse 'اطلاعاتی-بانک' in Neutral
SELECT * FROM sys.dm_fts_parser(N'بانک-اطلاعاتی', 0, 0, 0);
GO
