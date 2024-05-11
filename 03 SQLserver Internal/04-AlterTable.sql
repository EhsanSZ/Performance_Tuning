
--ساخت بانک اطلاعاتی برای بررسی فایل های مربوط به آن
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017
GO
USE MyDB2017
GO
-------------------------------
--ایجاد جدول تستی
DROP TABLE IF EXISTS AlterDemo
GO
CREATE TABLE AlterDemo
(
	ID int not null,
	Col1 int null,
	Col2 bigint null,
	Col3 char(10) null,
	Col4 tinyint null
)
GO
--همه با هم اجرا شود
--مشاهده فیلدها به آفست های توجه شود
SELECT
	c.column_id, c.Name, ipc.leaf_offset as [Offset in Row]
	,ipc.max_inrow_length as [Max Length], ipc.system_type_id as [Column Type]
FROM sys.system_internals_partition_columns ipc 
	INNER JOIN sys.partitions p on ipc.partition_id = p.partition_id
	INNER JOIN sys.columns c on c.column_id = ipc.partition_column_id and c.object_id = p.object_id
WHERE 
	p.object_id = object_id(N'AlterDemo')
ORDER BY c.column_id;
GO
--حذف و ویرایش تعدادی از فیلدهای جدول
ALTER TABLE dbo.AlterDemo DROP COLUMN  Col1
ALTER TABLE dbo.AlterDemo ALTER COLUMN Col2 TINYINT
ALTER TABLE dbo.AlterDemo ALTER COLUMN Col3 CHAR(1)
ALTER TABLE dbo.AlterDemo ALTER COLUMN Col4 INT
GO
--مشاهده فیلدها به آفست های توجه شود
--عوض نشده است Col2,Col3 آفست Col1 با وجود حذف 
SELECT
	c.column_id, c.Name, ipc.leaf_offset as [Offset in Row]
	,ipc.max_inrow_length as [Max Length], ipc.system_type_id as [Column Type]
FROM sys.system_internals_partition_columns ipc 
	INNER JOIN sys.partitions p on ipc.partition_id = p.partition_id
	INNER JOIN sys.columns c on c.column_id = ipc.partition_column_id and c.object_id = p.object_id
WHERE 
	p.object_id = object_id(N'AlterDemo')
ORDER BY c.column_id;
GO
--آفست های تغییری نکرده اند Alter پس از انجام عملیات
--در این حالت فضا هدر رفته است
GO
--شود Rebuild پس از انجام این نوع کارها باید جدول 
ALTER TABLE AlterDemo REBUILD
GO
SELECT
	c.column_id, c.Name, ipc.leaf_offset as [Offset in Row]
	,ipc.max_inrow_length as [Max Length], ipc.system_type_id as [Column Type]
FROM sys.system_internals_partition_columns ipc 
	INNER JOIN sys.partitions p on ipc.partition_id = p.partition_id
	INNER JOIN sys.columns c on c.column_id = ipc.partition_column_id and c.object_id = p.object_id
WHERE 
	p.object_id = object_id(N'AlterDemo')
ORDER BY c.column_id;
GO
