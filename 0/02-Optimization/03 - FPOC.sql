
USE WF;
GO

DROP INDEX IF EXISTS
	Sales.Orders.NCIX_CidEid,
	Sales.Orders.NCIC_CidEid_Odate,
	Sales.Orders.NCIX_CidEid_OidF,
	Sales.Orders.NCIX_CidEid_F,
	Sales.Orders.NCIX_OidCidEid_F;
GO

SP_HELPINDEX 'Sales.Orders';
GO

-- ایندکس مناسب برای کوئری زیر چیست؟
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid)
FROM Sales.Orders;
GO

/*
POC ایجاد ایندکس مطابق با روال
از کوئری Sort و حذف اپراتور
Performance و افزایش چشمگیر
*/
DROP INDEX IF EXISTS Sales.Orders.NCIX_CidEid;
GO
CREATE INDEX NCIX_CidEid ON Sales.Orders(custid, empid);
GO

-- مقایسه دو کوئری زیر
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid) AS Row_Num
FROM Sales.Orders;
GO
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid) AS Row_Num
FROM Sales.Orders WITH(INDEX(PK_Orders));
GO

-- WHERE به‌دلیل وجود بخش NCIX_CidEid عدم استفاده از ایندکس
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid) AS Row_Num
FROM Sales.Orders
	WHERE orderdate BETWEEN '20170101' AND '20171231';
GO

/*
مقایسه دو کوئری زیر
NCIX_CidEid اجبار به‌استفاده از ایندکس
!مناسب نیست NCIX_CidEid از کوئری حذف شده است اما ایندکس Sort اپراتور
.کارآیی بهتری خواهیم داشت Lookup به‌دلیل حذف PK_Orders اما در صورت استفاده از ایندکس
*/
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid) AS Row_Num
FROM Sales.Orders
	WHERE orderdate BETWEEN '20170101' AND '20171231';;
GO
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid) AS Row_Num
FROM Sales.Orders WITH(INDEX(NCIX_CidEid))
	WHERE orderdate BETWEEN '20170101' AND '20171231';
GO

/*
FPOC ایجاد ایندکس مطابق با روال
از کوئری Sort حذف اپراتور
Performance افزایش چشمگیر
*/
DROP INDEX IF EXISTS Sales.Orders.NCIC_CidEid_Odate;
GO
CREATE INDEX NCIC_CidEid_Odate ON Sales.Orders(custid,empid) INCLUDE(orderdate);
GO

-- مقایسه کوئری‌های زیر
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid) AS Row_Num
FROM Sales.Orders
	WHERE orderdate BETWEEN '20170101' AND '20171231';
GO
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid)
FROM Sales.Orders WITH(INDEX(NCIX_CidEid))
	WHERE orderdate BETWEEN '20170101' AND '20171231';
GO
SELECT
	custid, empid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY empid)
FROM Sales.Orders WITH(INDEX(PK_Orders))
	WHERE orderdate BETWEEN '20170101' AND '20171231';
GO
--------------------------------------------------------------------

/*
?ایندکس مناسب برای کوئری زیر چیست
*/

SELECT
	custid, freight,
	ROW_NUMBER() OVER(PARTITION BY custid	ORDER BY empid)
FROM Sales.Orders
	WHERE orderid > 10249;
GO

SP_HELPINDEX 'Sales.Orders';
GO

SELECT 
	I.name,	C.Name,
	CASE I_C.is_included_column
		WHEN 0 THEN 'Key'
	ELSE 'Include' END AS Typ
FROM sys.indexes AS I
JOIN sys.index_columns AS I_C
	ON I_C.object_id = I.object_id
	AND I_C.index_id = I.index_id
JOIN sys.columns AS C
	ON C.object_id = I_C.object_id
	AND C.column_id = I_C.column_id
	WHERE I.name = 'NCIC_CidEid_Odate';
GO

-- Primary Key استفاده از ایندکس موجود بر روی
SELECT
	custid, freight,
	ROW_NUMBER() OVER(PARTITION BY custid	ORDER BY empid)
FROM Sales.Orders
	WHERE orderid > 10249;
GO

DROP INDEX IF EXISTS Sales.Orders.NCIX_CidEid_OidF;
GO
CREATE INDEX NCIX_CidEid_OidF ON Sales.Orders(custid, empid) INCLUDE(orderid,freight);
GO

-- مقایسه دو کوئری زیر
SELECT
	custid, freight,
	ROW_NUMBER() OVER(PARTITION BY custid	ORDER BY empid)
FROM Sales.Orders
	WHERE orderid > 10249;
GO
SELECT
	custid, freight,
	ROW_NUMBER() OVER(PARTITION BY custid	ORDER BY empid)
FROM Sales.Orders WITH(INDEX(PK_Orders))
	WHERE orderid > 10249;
GO

-- ایجاد چند ایندکس دیگر
DROP INDEX IF EXISTS Sales.Orders.NCIX_CidEid_F;
GO
CREATE INDEX NCIX_CidEid_F ON Sales.Orders(custid,empid) INCLUDE(freight);
GO

DROP INDEX IF EXISTS Sales.Orders.NCIX_OidCidEid_F;
GO
CREATE INDEX NCIX_OidCidEid_F ON Sales.Orders(orderid,custid,empid) INCLUDE(freight);
GO

SET STATISTICS IO ON;
GO

-- مقایسه کوئری‌های زیر
SELECT
	custid, freight,
	ROW_NUMBER() OVER(PARTITION BY custid	ORDER BY empid)
FROM Sales.Orders WITH(INDEX(NCIX_OidCidEid_F))
	WHERE orderid > 10249;
GO
SELECT
	custid, freight,
	ROW_NUMBER() OVER(PARTITION BY custid	ORDER BY empid)
FROM Sales.Orders WITH(INDEX(NCIX_CidEid_F))
	WHERE orderid > 10249;
GO
SELECT
	custid, freight,
	ROW_NUMBER() OVER(PARTITION BY custid	ORDER BY empid)
FROM Sales.Orders WITH(INDEX(NCIX_CidEid_OidF))
	WHERE orderid > 10249;
GO
SELECT
	custid, freight,
	ROW_NUMBER() OVER(PARTITION BY custid	ORDER BY empid)
FROM Sales.Orders WITH(INDEX(PK_Orders))
	WHERE orderid > 10249;
GO

DROP INDEX IF EXISTS
	Sales.Orders.NCIX_CidEid,
	Sales.Orders.NCIC_CidEid_Odate,
	Sales.Orders.NCIX_CidEid_OidF,
	Sales.Orders.NCIX_CidEid_F,
	Sales.Orders.NCIX_OidCidEid_F;
GO