
/*
Implicit Conversion عدم استفاده از 
*/
--Show Actual Execution Plan 
SET STATISTICS IO ON 
SET STATISTICS TIME ON 
GO
USE AdventureWorks2017
GO
--بررسی ساختار فیلد کد ملی
SP_HELP 'HumanResources.Employee'
GO
--تفاوت دقیق ایندکس های مورد استفاده بررسی شود
SELECT E.BusinessEntityID,E.NationalIDNumber,E.LoginID
	 FROM HumanResources.Employee E
		WHERE E.NationalIDNumber=993310268
GO
SELECT E.BusinessEntityID,E.NationalIDNumber,E.LoginID
	 FROM HumanResources.Employee E
		WHERE E.NationalIDNumber='993310268'
GO
