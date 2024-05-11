
--NonClustered Index معرفی 
USE tempdb
GO
--بررسی جهت وجود جدول
DROP TABLE IF EXISTS Customers
GO
--ایجاد جدول
CREATE TABLE Customers
(
   CustomerID INT NOT NULL,
   CustomerName CHAR(100) NOT NULL,
   CustomerAddress CHAR(100) NOT NULL,
   Comments CHAR(185) NOT NULL,
   Value INT NOT NULL
)
GO
-------------------------
--Clustered Index ایجاد ایندکس 
CREATE UNIQUE CLUSTERED INDEX IX_Customers ON Customers(CustomerID)
GO
--NonClustered Index ایجاد ایندکس 
CREATE UNIQUE NONCLUSTERED INDEX IX_Value ON Customers(Value)
GO
-------------------------
--درج هشتاد هزار رکورد در جدول
SET NOCOUNT ON
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
	SET @i += 1
END
GO
SELECT * FROM Customers
-------------------------
--بررسی ایندکس های موجود در جدول 
SP_HELPINDEX 'Customers'
GO
--IO فعال کردن آمار
SET STATISTICS IO ON
GO
--آن Execution Plan استخراج یک رکورد و مشاهده 
SELECT * FROM Customers
	WHERE Value=1023
GO
--آن Execution Plan استخراج یک رکورد و مشاهده 
SELECT * FROM Customers WITH(INDEX(0))
	WHERE Value=1023
GO
--IO غیر فعال کردن آمار
SET STATISTICS IO OFF
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Bookmark Lookupبررسی مفهوم 

--IO فعال کردن آمار
SET STATISTICS IO ON
GO
--کوئری Execution Plan مشاهده 
SELECT * FROM Customers
	WHERE Value=1023
GO
--کوئری Execution Plan مشاهده 
SELECT CustomerID,Value FROM Customers
	WHERE Value=1023
GO
SELECT *  FROM Customers
	WHERE Value<1062
GO
--IO غیر فعال کردن آمار
SET STATISTICS IO OFF
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Tipping Point بررسی مفهوم 

--IO فعال کردن آمار
SET STATISTICS IO ON
GO
--کوئری ها یکسان اما پلن متفاوت
SELECT *  FROM Customers
	WHERE Value<1063
GO
SELECT *  FROM Customers
	WHERE Value<1200
GO
SELECT *  FROM Customers WITH(INDEX(IX_VALUE))
	WHERE Value<1200
GO
--IO غیر فعال کردن آمار
SET STATISTICS IO OFF
GO