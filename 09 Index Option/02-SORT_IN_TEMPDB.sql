----
/*
 هنگام ایجاد ایندکسSort_In_TempDB بررسی استفاده از ویژگی 
 TempDB را ریستارت کنیم تا بانک اطلاعاتی SQL Server برای دمو بهتر است سرویس 
 مجدد تنظیماتش اعمال گردد
*/
USE master
GO
IF DB_ID('DemoPageOrganization')>0
BEGIN
	ALTER DATABASE DemoPageOrganization SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DemoPageOrganization
END
GO
RESTORE FILELISTONLY FROM DISK ='C:\Temp\DemoPageOrganization.bak'
GO
--بازیابی بانک اطلاعاتی
RESTORE DATABASE DemoPageOrganization FROM DISK ='C:\Temp\DemoPageOrganization.bak' WITH 
	MOVE 'DemoPageOrganization' TO 'C:\Temp\DemoPageOrganization.mdf',
	MOVE 'DemoPageOrganization_log' TO 'C:\Temp\DemoPageOrganization_log.lmdf',
	STATS=1
GO
--قبل از ساخت ایندکس Tempdbبررسی حجم بانک اطلاعاتی 
USE tempdb
EXEC SP_HELPFILE
GO
--ساخت ایندکس با کلیدی
USE DemoPageOrganization
GO
DROP INDEX IF EXISTS IX_Clustered ON HeapTable
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON HeapTable(OrderDateKey,SalesOrderNumber,ProductKey,SalesOrderLineNumber)
--	WITH (SORT_IN_TEMPDB=ON)
GO
--پس از ساخت ایندکس Tempdbبررسی حجم بانک اطلاعاتی 
USE tempdb
GO
EXEC SP_HELPFILE
GO
/*
ریستارت شود SQL Server در انتها یک بار دیگر سرویس 
ساخته شود SORT_IN_TEMPDB ایندکس مجدد بدون 
*/


