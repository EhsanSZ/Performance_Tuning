
/*
در ایندکس هاWith استفاده از بخش
*/
USE Northwind
GO
CREATE INDEX IX_OrderDate ON Orders(OrderDate)
WITH 
(
	PAD_INDEX = { ON | OFF } ,
	FILLFACTOR = FillFactor,
	SORT_IN_TEMPDB = { ON | OFF },
	IGNORE_DUP_KEY = { ON | OFF },
	STATISTICS_NORECOMPUTE = { ON | OFF },
	STATISTICS_INCREMENTAL = { ON | OFF },
	DROP_EXISTING = { ON | OFF },
	ONLINE = { ON | OFF },
	ALLOW_ROW_LOCKS = { ON | OFF },
	ALLOW_PAGE_LOCKS = { ON | OFF },
)
