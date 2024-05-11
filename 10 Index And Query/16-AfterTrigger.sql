
USE tempdb
GO
IF OBJECT_ID('Data')>0
	DROP TABLE Data
GO
--ایجاد جدول
create table dbo.Data
(
	ID int not null identity(1,1),
	Value int not null,
	LobColumn varchar(max) null,
	constraint PK_Data
	primary key clustered(ID)
);
--درج دیتا تستی
;with N1(C) as (select 0 union all select 0) -- 2 rows
,N2(C) as (select 0 from N1 as T1 cross join N1 as T2) -- 4 rows
,N3(C) as (select 0 from N2 as T1 cross join N2 as T2) -- 16 rows
,N4(C) as (select 0 from N3 as T1 cross join N3 as T2) -- 256 rows
,N5(C) as (select 0 from N4 as T1 cross join N4 as T2 ) -- 65,536 rows
,Numbers(Num) as (select row_number() over (order by (select null)) from N5)
insert into dbo.Data(Value)
          select Num
  from Numbers;
GO
--مشاهده رکوردهای درج شده
SP_SPACEUSED 'Data'
GO
--ایندکس های موجود در جدولFragmentation بررسی وضعیت 
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Data'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
--حذف رکورد
delete from dbo.Data where ID % 2 = 0;
GO
--ایندکس های موجود در جدولFragmentation بررسی وضعیت 
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Data'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
--------------------------------------------------------------------
--پاک کردن کلیه رکوردهای جودل 
TRUNCATE TABLE dbo.Data;
GO
--درج دیتا تستی
;with N1(C) as (select 0 union all select 0) -- 2 rows
,N2(C) as (select 0 from N1 as T1 cross join N1 as T2) -- 4 rows
,N3(C) as (select 0 from N2 as T1 cross join N2 as T2) -- 16 rows
,N4(C) as (select 0 from N3 as T1 cross join N3 as T2) -- 256 rows
,N5(C) as (select 0 from N4 as T1 cross join N4 as T2 ) -- 65,536 rows
,Numbers(Num) as (select row_number() over (order by (select null)) from N5)
insert into dbo.Data(Value)
        select Num
from Numbers;
GO
--مشاهده رکوردهای درج شده
SP_SPACEUSED 'Data'
GO
--ایجاد یک تریگر
create trigger trg_Data_AfterDelete on dbo.data after delete
as
return;
GO
--ایندکس های موجود در جدولFragmentation بررسی وضعیت 
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Data'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO
--حذف رکورد
delete from dbo.Data where ID % 2 = 0;
GO
--ایندکس های موجود در جدولFragmentation بررسی وضعیت 
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count,
	s.avg_fragment_size_in_pages,s.avg_fragmentation_in_percent,
	s.fragment_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('Data'),NULL,NULL,'DETAILED') S
	WHERE  index_level=0
GO

/*
CREATE TABLE St
(
	ID INT PRIMARY KEY,
	FullName NVARCHAR(100)
)

GO
INSERT INTO St(ID,FullName) VALUES (1,'A')

UPDATE St SET FullName='AAA' WHERE ID=1

create trigger trg_Data_AfterUpdate on dbo.St after UPDATE
as
SELECT * FROM inserted
SELECT * FROM deleted

*/