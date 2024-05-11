
--Row Overflow بررسی 
USE master
GO
--بررسي جهت وجود بانك اطلاعاتي و حذف آن
IF DB_ID('AllocationUnitsDemo')>0
	DROP DATABASE AllocationUnitsDemo
GO	
--ايجاد بانك اطلاعاتي
CREATE DATABASE AllocationUnitsDemo
GO
Use AllocationUnitsDemo
GO
--مشاهده فايل هاي مربوط به بانك اطلاعاتي
SP_HELPFILE
SELECT * FROM sys.database_files
GO
------------------------------------------------------------
--IN_ROW_DATA 
------------------------------------------------------------
--بررسي جهت وجود جدول و بررسي آن
IF OBJECT_ID('IN_ROW_Table')>0
	DROP TABLE IN_ROW_Table
GO	
--IN_ROW_DATA :8060 Byte
--Total length of the row in this table is 1000 + 4000 = 5000 (< 8000)
--ايجاد جدول
CREATE TABLE IN_ROW_Table
(
	ProductName CHAR(1000),
	ProductDesc CHAR (4000)
)
GO
--بررسي حجم جدول
SP_SPACEUSED IN_ROW_Table
GO
--Allocation Unit Uype چك كزدن 
SELECT type_desc, total_pages, used_pages,data_pages 
FROM sys.allocation_units S
WHERE container_id =
	(
		SELECT partition_id FROM sys.partitions 
			WHERE OBJECT_ID = OBJECT_ID('IN_ROW_Table')
	)
GO
INSERT INTO IN_ROW_Table(ProductName,ProductDesc) 
	VALUES ('Computer','CPU :Core I7')
GO 100
--بررسي حجم جدول
SP_SPACEUSED IN_ROW_Table
GO
--Allocation Unit Uype چك كزدن 
SELECT type_desc, total_pages, used_pages,data_pages 
FROM sys.allocation_units S
WHERE container_id =
	(
		SELECT partition_id FROM sys.partitions 
			WHERE OBJECT_ID = OBJECT_ID('IN_ROW_Table')
	)
GO
--IOبررسي وضعيت  
SET STATISTICS IO ON 
SELECT * FROM IN_ROW_Table
SET STATISTICS IO OFF
GO
--هاي جدولPage مشاهده 
DBCC IND(AllocationUnitsDemo,'IN_ROW_Table',-1) WITH NO_INFOMSGS;--همه ركوردها توجه iam_chanin_type به فيلد 
------------------------------------------------------------
--ROW_OVERFLOW_DATA
------------------------------------------------------------
--بررسي جهت وجود جدول و بررسي آن
IF OBJECT_ID('Overflow_Table')>0
	DROP TABLE Overflow_Table
GO	
--ROW_OVERFLOW_DATA
--Total length of the row in this table is 1000 + 4000 + 4000= 9000 (> 8000)
--ايجاد جدول
CREATE TABLE Overflow_Table
(
	ProductName CHAR(1000),
	ProductDesc1 CHAR (4000),
	ProductDesc2 VARCHAR(4000) --به اين فيلد توجه كنيد
)
GO
--بررسي حجم جدول
SP_SPACEUSED Overflow_Table
GO
--Allocation Unit Uype چك کردن 
SELECT type_desc, total_pages, used_pages,data_pages 
FROM sys.allocation_units S
WHERE container_id =
	(
		SELECT partition_id FROM sys.partitions 
			WHERE OBJECT_ID = OBJECT_ID('Overflow_Table')
	)
GO
INSERT INTO Overflow_Table(ProductName,ProductDesc1,ProductDesc2) 
	VALUES ('Computer','CPU :Core I7',REPLICATE('D',4000))
GO 100
--بررسي حجم جدول
SP_SPACEUSED Overflow_Table
GO
--Allocation Unit Uype چك كزدن 
SELECT type_desc, total_pages, used_pages,data_pages 
FROM sys.allocation_units S
WHERE container_id =
	(
		SELECT partition_id FROM sys.partitions 
			WHERE OBJECT_ID = OBJECT_ID('Overflow_Table')
	)
GO
--IOبررسي وضعيت  
SET STATISTICS IO ON 
SELECT * FROM Overflow_Table
SET STATISTICS IO OFF
GO
--هاي جدولPage مشاهده 
DBCC IND(0,'Overflow_Table',-1) WITH NO_INFOMSGS;
