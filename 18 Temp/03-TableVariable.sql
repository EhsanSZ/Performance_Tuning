
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('Temp_Test')>0
BEGIN
	ALTER DATABASE Temp_Test SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Temp_Test
END
GO
--ایجاد بانک اطلاعاتی
CREATE DATABASE Temp_Test
GO
USE Temp_Test
GO
--------------------------------------------------------------------
--ایجاد متغییر جدولی
DECLARE @TableVariable TABLE
(
	EmployeeID INT,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100)
)

INSERT INTO @TableVariable(EmployeeID,FirstName,LastName) 
	VALUES (1,N'مسعود',N'طاهری')
SELECT * FROM @TableVariable
GO
--------------------------------------------------------------------
--Transaction چک کردن
DECLARE @TableVariable TABLE
(
	EmployeeID INT,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100)
)
BEGIN TRANSACTION
INSERT INTO @TableVariable(EmployeeID,FirstName,LastName) 
	VALUES (1,N'مسعود',N'طاهری')
ROLLBACK TRANSACTION
SELECT * FROM @TableVariable
GO
--بررسی سناریو مورد استفاده 
--Try...Catch
/*
BEGIN TRY
	DECLARE @TableVariable_Log TABLE
	(
		LogID INT,
		Description NVARCHAR(100)
	)
	BEGIN TRANSACTION
	INSERT INTO @TableVariable_Log VALUES(1,N'اجرای بخش اول')
	/*
	Section 1
	ASDAS
	ASDAS
	ASDAS
	*/

	INSERT INTO @TableVariable_Log VALUES(2,N'اجرای بخش دوم')
	/*
	Section 2
	ASDAS
	ASDAS
	ASDAS
	*/

	INSERT INTO @TableVariable_Log VALUES(3,N'اجرای بخش سوم')
	/*
	Section 3
	ASDAS
	ASDAS
	ASDAS
	*/
	IF @@TRANCOUNT>0	
		COMMIT TRAN
END TRY

BEGIN CATCH
	
	IF @@TRANCOUNT>0	
		ROLLBACK TRAN	
END CATCH
*/
--------------------------------------------------------------------
--Disconnect & Connect
--کلیه این دستورات با هم ایجاد شوند
SELECT 'Before Create Table Variable'
GO
SELECT @@SPID AS Current_SessionID
GO
--TempDb جاری در Session صفحات استفاده شده
SELECT 
	user_objects_alloc_page_count,
	user_objects_dealloc_page_count 
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO
--ایجاد یک متغییر جدولی و درج تعدادی رکورد تستی
DECLARE @temp TABLE(Col1 INT)
INSERT INTO @temp (Col1)
SELECT TOP 3000 ROW_NUMBER() OVER(ORDER BY a.name) 
	FROM sys.all_objects a CROSS JOIN sys.all_objects b
GO
SELECT 'After Create Table Variable'
GO
--TempDb جاری در Session صفحات استفاده شده
SELECT 
	user_objects_alloc_page_count,
	user_objects_dealloc_page_count 
FROM sys.dm_db_session_space_usage
	WHERE session_id = (SELECT @@SPID )
GO
