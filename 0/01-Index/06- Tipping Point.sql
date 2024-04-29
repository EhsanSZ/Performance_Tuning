
USE Index_DB;
GO

DROP TABLE IF EXISTS Customers;
GO
-- ایجاد جدول تستی
CREATE TABLE Customers
(
   CustomerID INT NOT NULL,
   CustomerName CHAR(100) NOT NULL,
   CustomerAddress CHAR(100) NOT NULL,
   Comments CHAR(185) NOT NULL,
   Val INT NOT NULL
);
GO

-- Clustered Index ایجاد ایندکس 
CREATE UNIQUE CLUSTERED INDEX IX_Customers ON Customers(CustomerID);
GO

-- NonClustered Index ایجاد ایندکس 
CREATE NONCLUSTERED INDEX IX_Value ON Customers(Val);
GO

-- درج هشتاد هزار رکورد در جدول تستی
SET NOCOUNT ON;
DECLARE @i INT = 1
WHILE (@i <= 80000)
BEGIN
	INSERT INTO Customers VALUES
	(
	   @i,
	   'CustomerName' + CAST(@i AS CHAR),
	   'CustomerAddress' + CAST(@i AS CHAR),
	   'Comments' + CAST(@i AS CHAR),
	   @i
	)
	SET @i += 1;
END
GO

SELECT * FROM Customers;
GO

-- بررسی ایندکس های موجود در جدول 
SP_HELPINDEX 'Customers';
GO

SET STATISTICS IO ON;
GO

SELECT * FROM Customers
	WHERE Val = 1023;
GO

SELECT * FROM Customers WITH(INDEX(0))
	WHERE Val = 1023;
GO

-- ?داریم Bookmark Lookup آیا
SELECT
	CustomerID, Val
FROM Customers
	WHERE Val = 1023;
GO

SELECT *  FROM Customers
	WHERE Val < 789;
GO

SELECT *  FROM Customers
	WHERE Val < 790;
GO

-- .منصرف می‌شود Lookup از انجام Tipping Point با استفاده از مفهوم
SELECT *  FROM Customers
	WHERE Val < 2000;
GO

SELECT *  FROM Customers WITH(INDEX(IX_Value))
	WHERE Val < 2000;
GO