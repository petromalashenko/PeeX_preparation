IF OBJECT_ID(N'dbo.salequotas', N'U') IS NOT NULL
  DROP TABLE dbo.salequotas;
GO
CREATE TABLE dbo.salequotas
(
	employeeid INT,
	firstname  VARCHAR(20),
	lastname   VARCHAR(20),
	category   VARCHAR(20),
	quota      NUMERIC(7,2)
);

IF OBJECT_ID(N'dbo.sales', N'U') IS NOT NULL
  DROP TABLE dbo.sales;
GO
CREATE TABLE dbo.sales
(
	employeeid INT,
	category   VARCHAR(20),
	amount     NUMERIC(7,2)
);
GO

CREATE OR ALTER FUNCTION dbo.ufn_totalsales ( @EmployeeId INT, @Category VARCHAR(20) )
returns TABLE 
AS 
RETURN
(
	SELECT amount
	  FROM dbo.sales
	 WHERE employeeid=@EmployeeId
	   AND category=@Category
);
GO
  

INSERT INTO SaleQuotas VALUES (1,'John','Adams', 'Fruits', 10000 );
GO
INSERT INTO SaleQuotas VALUES (1,'John','Adams', 'Textile', 12000 );
GO
INSERT INTO SaleQuotas VALUES (1,'John','Adams', 'Food', 12000);
GO
INSERT INTO SaleQuotas VALUES (2,'Maxym','Anton', 'Fruits', 11000);
GO
INSERT INTO SaleQuotas VALUES (2,'Maxym','Anton', 'Textile', 12000 );
GO
INSERT INTO SaleQuotas VALUES (2,'Maxym','Anton', 'Food', 10000);
GO
INSERT INTO SaleQuotas VALUES (3,'Oleg','Buryagin', 'Fruits', 14000 );
GO
INSERT INTO SaleQuotas VALUES (3,'Oleg','Buryagin', 'Textile', 16000);
GO
INSERT INTO SaleQuotas VALUES (4,'Anna','Lev', 'Fruits', 15000 );
GO
INSERT INTO SaleQuotas VALUES (4,'Anna','Lev', 'Textile', 11000);
GO
INSERT INTO SaleQuotas VALUES (4,'Anna','Lev', 'Food', 16000 );
GO 

INSERT INTO Sales  VALUES (1, 'Fruits', 12000 );
GO
INSERT INTO Sales  VALUES (1, 'Textile', 13000 );
GO
INSERT INTO Sales  VALUES (2, 'Fruits', 9000);
GO
INSERT INTO Sales  VALUES (2, 'Textile', 12000 );
GO
INSERT INTO Sales  VALUES (2, 'Food', 10000);
GO
INSERT INTO Sales  VALUES (3, 'Fruits', 13000 );
GO
INSERT INTO Sales  VALUES (4,'Fruits', 15000 );
GO
INSERT INTO Sales  VALUES (4,'Food', 16000 );
GO

-------------------------------------
--TASKS RESOLUTION
-------------------------------------

--1 Seller, Category, and Quota from SaleQuotas table and Amount from ufn_TotalSales function only for sellers with Sale

SELECT sq.firstname + ' ' + sq.lastname AS seller,
       sq.category,
       sq.quota,
       ts.amount
FROM   dbo.salequotas sq
       CROSS APPLY dbo.ufn_totalsales(sq.employeeid, sq.category) ts
; 


-- 2 Seller, Category, and Quota from SalesQuotas table and Amount from ufn_TotalSales function for all sellers

SELECT sq.firstname + ' ' + sq.lastname AS Seller,
       sq.category,
       sq.quota,
       ts.amount
FROM   dbo.salequotas sq
       OUTER APPLY dbo.ufn_totalsales(sq.employeeid, sq.category) ts
; 