
USE AdventureWorks2017
GO
--تمرین
USE MyDB2017
GO
DROP TABLE IF EXISTS ClusteredTable
GO
--ایجاد جدول با حجم بالا
CREATE TABLE ClusteredTable
(
	ID CHAR(900),
	FirstName CHAR(3000) DEFAULT 'A',
	LastName CHAR(3000) DEFAULT 'B'
)
GO
CREATE CLUSTERED INDEX Clustered_IX ON ClusteredTable(ID)
GO
--درج رکوردهای تستی
INSERT INTO ClusteredTable(ID) VALUES
(1),(2),(3),(4),(5),
(6),(7),(8),(9),(10)
GO
SELECT * FROM ClusteredTable
GO
--آنالیز ایندکس
SELECT 
	index_id,index_type_desc,
	index_depth,index_level,
	page_count,record_count 
FROM sys.dm_db_index_physical_stats
(
	DB_ID('MyDB2017'),
	OBJECT_ID('ClusteredTable'),
	NULL,
	NULL,
	'DETAILED'
)
GO
/*
شکل درخت با استفاده از برگه تمرین در 
کشیده شود Power Point
*/

