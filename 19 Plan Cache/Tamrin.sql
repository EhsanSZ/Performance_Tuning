DROP TABLE IF EXISTS Customer
GO
CREATE TABLE Customer
(
  ID INT PRIMARY KEY IDENTITY(1,1),
  CustCode INT,
  CustName NVARCHAR(200),
  ContactNumber INT,
  Address NVARCHAR(255)
)
GO
CREATE OR ALTER PROCEDURE USP_GetCustomer
(
  @CustCode INT,
  @CustName NVARCHAR(200)
)
AS
BEGIN
	SELECT 
		ID,
		CustCode,
		CustName,
		ContactNumber,
		Address
	FROM
		Customer
WHERE 
	(CustCode=@CustCode OR @CustCode IS NULL)
	AND  (CustName=@CustName OR @CustName IS NULL)
END
GO