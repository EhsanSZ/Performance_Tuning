
 
 /*به ترتيب اجراي قسمت هاي اين دستور توجه شود
	1-FROM
	2-WHERE
	3-GROUP BY
	4-HAVING
	5-SELECT
	6-ORDER BY 
*/
USE AdventureWorks2017
GO
SELECT SalesPersonID, YEAR(orderdate) AS OrderYear,COUNT(*) AS NumOrders --5:SELECT
	FROM Sales.SalesOrderHeader --1:FROM
		WHERE CustomerID = 29994 --2:WHERE
			GROUP BY SalesPersonID, YEAR(OrderDate) --3:GROUP BY
				HAVING COUNT(*) > 1 --4:HAVING
					ORDER BY OrderYear DESC --6:ORDER BY 
GO