
--Delete بررسی عملکرد دستور 
--------------------------------------------------------------------
--GHOST CLEANUP مشاهده پروسه 
DECLARE @Gh NVARCHAR(1000)=''
DECLARE @ST DATETIME
WHILE (@Gh='')
BEGIN
		SELECT @Gh=command ,@ST=start_time From sys.dm_exec_requests Where COMMAND like '%GHOST%';
End
SELECT  @Gh
SELECT  @ST
GO

DECLARE @Gh NVARCHAR(1000)=''
DECLARE @ST DATETIME
WHILE (1=1)
BEGIN
		DROP TABLE IF EXISTS #T1
		SELECT * INTO #T1 From sys.dm_exec_requests Where COMMAND like '%GHOST%';
		IF EXISTS(SELECT * FROM #T1)
			SELECT * FROM #T1
End
GO
--------------------------------------------------------------------
--ایجاد یک بانک اطلاعاتی جدید
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
ALTER DATABASE MyDB2017 SET RECOVERY SIMPLE
GO
USE MyDB2017
GO
DROP TABLE IF EXISTS DeleteInternals
GO
--ایجاد جدول جدید
CREATE TABLE DeleteInternals
(
	ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name CHAR(4) NOT NULL
)
GO
--------------------------------------------------------------------
--درج رکوردهای تستی
INSERT INTO DeleteInternals(Name) VALUES('Row1')
INSERT INTO DeleteInternals(Name) VALUES('Row2')
INSERT INTO DeleteInternals(Name) VALUES('Row3')
INSERT INTO DeleteInternals(Name) VALUES('Row4')
GO
--مشاهده رکوردهای درج شده در جدول
SELECT * FROM DeleteInternals
GO
--استخراج پیج های متعلق به جدول
DBCC IND(MyDB2017, DeleteInternals, 1) 
DBCC TRACEON(3604)
GO
--Page Header در m_ghostRecCnt,m_slotCnt بررسی
DBCC PAGE(MyDB2017, 1,328,2) 
GO
--حذف یک رکورد تستی
BEGIN TRANSACTION 
DELETE FROM DeleteInternals where Id = 2 
DBCC PAGE(MyDB2017, 1,328,2) 
/*
--Page Header در m_ghostRecCnt,m_slotCnt بررسی
--Data Row در RecordType بررسی
--Row Offset بررسی 
*/
--مشاهده کرد NOLOCK را می توان با Ghost Record آیا 
SELECT * FROM DeleteInternals WITH (NOLOCK)
GO
--------------------------------------------------------------------
COMMIT TRANSACTION 
GO
DBCC PAGE(MyDB2017, 1,328,2) 
GO
/*
--Page Header در m_ghostRecCnt,m_slotCnt بررسی
--Data Row در RecordType بررسی
--Row Offset بررسی 
*/
--------------------------------------------------------------------
--GHOST RECORD کنترل اجرای پروسه 
DBCC TRACEON (661, -1)
