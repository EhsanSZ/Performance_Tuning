
USE tempdb
GO
--بررسی وجود جداول و پاک کردن آن
DROP TABLE IF EXISTS Customers
DROP TABLE IF EXISTS Orders
GO
--ایجاد جدول تستی
CREATE TABLE Customers
(
	CustID INT IDENTITY PRIMARY KEY,
	CustName VARCHAR(50) NOT NULL
)
GO
CREATE TABLE Orders
(
	OrderID INT IDENTITY PRIMARY KEY,
	CustID INT NOT NULL
)
GO
--Show Execution Plan
SELECT * FROM Orders AS O
WHERE EXISTS
(
	SELECT * FROM Customers AS C
	WHERE C.CustID = O.CustID
)
GO
--فعال باشد کوئری بالا هم ارز کوئری زیر می باشدRelation اگر 
SELECT * FROM Orders AS O
GO
--Relation ایجاد
ALTER TABLE Orders ADD CONSTRAINT FK_CustID FOREIGN KEY (CustID)
	REFERENCES Customers (CustID)	
GO
--Show Execution Plan
SELECT * FROM Orders AS O
WHERE EXISTS
(
	SELECT * FROM Customers AS C
	WHERE C.CustID = O.CustID
)
GO
--Relation غیر فعال کردن
ALTER TABLE Orders NOCHECK CONSTRAINT FK_CustID
GO
--Show Execution Plan
SELECT * FROM Orders AS O
WHERE EXISTS
(
	SELECT * FROM Customers AS C
	WHERE C.CustID = O.CustID
)
GO
--Relation  فعال کردن
ALTER TABLE Orders CHECK CONSTRAINT FK_CustID
GO
--Show Execution Plan
/*
هنوز داده ها غیر قابل اعتماد هستند
*/
SELECT * FROM Orders AS O
WHERE EXISTS
(
	SELECT * FROM Customers AS C
	WHERE C.CustID = O.CustID
)
GO
--Relation  فعال کردن
ALTER TABLE Orders WITH CHECK CHECK CONSTRAINT FK_CustID
GO
--Show Execution Plan
SELECT * FROM Orders AS O
WHERE EXISTS
(
	SELECT * FROM Customers AS C
	WHERE C.CustID = O.CustID
)
GO
--------------------------------------------------------------------
--می باشد و ما می خواهیم رکورد درج کنیمRelation جدول دارای

--Master درج رکورد در جدول 
INSERT INTO Customers (custname) VALUES ('MasoudTaheri')
GO
--Show Execution Plan
SET STATISTICS IO ON 
GO
--Detail درج رکورد در جدول 
INSERT INTO Orders (CustID) VALUES (1)
GO
--Master حذف  رکورد از جدول 
DELETE FROM Customers WHERE CustID=1
/*
--غیر فعال می شودRelation در جداول خیلی خیلی بزرگ در برخی مواقع 
*/

/*
http://nikamooz.com/data-integrity-sql/
*/
