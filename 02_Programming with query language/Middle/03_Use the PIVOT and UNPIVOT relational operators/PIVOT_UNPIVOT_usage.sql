
IF OBJECT_ID(N'dbo.BranchTotalSales', N'U') IS NOT NULL
  DROP TABLE dbo.BranchTotalSales;
GO
CREATE TABLE dbo.BranchTotalSales
  (
     branch      VARCHAR(10),
     city        VARCHAR(99),
     productline VARCHAR(99),
     quantity    NUMERIC (14, 4),
     amount      NUMERIC (14, 4)
  )
;
GO

INSERT INTO dbo.BranchTotalSales VALUES 
('Small','Yangon','Textile',20,24), 
('Small','Yangon','Food',30,34), 
('Small','Yangon','Cosmetics',40,44), 
('Small','Yangon','Fruits',50,54), 
('Small','Yangon','Chemical',60,64), 
('Medium','Yangon','Textile',70,74), 
('Medium','Yangon','Food',80,84), 
('Medium','Yangon','Cosmetics',90,94), 
('Medium','Yangon','Fruits',100,104), 
('Medium','Yangon','Chemical',110,114), 
('Large','Yangon','Textile',120,124), 
('Large','Yangon','Food',130,134), 
('Large','Yangon','Cosmetics',140,144), 
('Large','Yangon','Fruits',150,154), 
('Large','Yangon','Technical',160,164), 
('Large','Yangon','Chemical',170,174), 
('Small','Naypyitaw','Textile',180,184), 
('Small','Naypyitaw','Food',190,194), 
('Small','Naypyitaw','Cosmetics',200,204), 
('Small','Naypyitaw','Fruits',210,214), 
('Small','Naypyitaw','Chemical',220,224), 
('Medium','Naypyitaw','Textile',230,234), 
('Medium','Naypyitaw','Food',240,244), 
('Medium','Naypyitaw','Cosmetics',250,254), 
('Medium','Naypyitaw','Fruits',260,264), 
('Medium','Naypyitaw','Chemical',270,274), 
('Large','Naypyitaw','Textile',280,284), 
('Large','Naypyitaw','Food',290,294), 
('Large','Naypyitaw','Cosmetics',300,304), 
('Large','Naypyitaw','Fruits',310,314), 
('Large','Naypyitaw','Chemical',320,324), 
('Large','Naypyitaw','Technical',330,334), 
('Medium','Mandalay','Textile',230,234), 
('Medium','Mandalay','Food',240,244), 
('Medium','Mandalay','Cosmetics',250,254), 
('Medium','Mandalay','Fruits',260,264), 
('Medium','Mandalay','Chemical',270,274), 
('Large', 'Mandalay','Textile',280,284), 
('Large', 'Mandalay','Food',290,294), 
('Large', 'Mandalay','Cosmetics',300,304), 
('Large', 'Mandalay','Fruits',310,314), 
('Large', 'Mandalay','Chemical',320,324), 
('Large', 'Mandalay','Technical',330,334)
;
GO


-------------------------
IF OBJECT_ID(N'dbo.pivotteddata', N'U') IS NOT NULL
  DROP TABLE dbo.pivotteddata;
GO
CREATE TABLE dbo.pivotteddata
  (
     branch    VARCHAR(10),
     city      VARCHAR(99),
     chemical  NUMERIC (14, 4),
     cosmetics NUMERIC (14, 4),
     food      NUMERIC (14, 4),
     fruits    NUMERIC (14, 4),
     technical NUMERIC (14, 4),
     textile   NUMERIC (14, 4)
  )
;
GO

INSERT INTO dbo.PivottedData 
VALUES  
('Large',	'Mandalay',	    324.0000,	304.0000,	294.0000,	314.0000,	334.0000,	NULL), 
('Medium',	'Mandalay',	    274.0000,	254.0000,	244.0000,	264.0000,	0.0000,	    234.0000), 
('Large',	'Naypyitaw',	324.0000,	NULL,	    294.0000,	314.0000,	334.0000,	284.0000), 
('Medium',	'Naypyitaw',	NULL,	    254.0000,	244.0000,	264.0000,	NULL,	    234.0000), 
('Small',	'Naypyitaw',	224.0000,	NULL,	    194.0000,	214.0000,	0.0000,	    184.0000), 
('Large',	'Yangon',       174.0000,	144.0000,	134.0000,	154.0000,	164.0000,	124.0000), 
('Medium',	'Yangon',	    114.0000,	94.0000,	84.0000,	104.0000,	NULL,	    74.0000	), 
('Small',	'Yangon',       64.0000,    44.0000,	34.0000,	54.0000,    NULL,	    24.0000	)
;
GO


--------------------------------
-- TASKS RESOLUTION
--------------------------------

-- 1 Retrieve Branch, City, and columns named ProductLines (Chemical, Cosmetics, Food, Fruits, Technical, and Textile).

SELECT branch,
       city,
       chemical,
       cosmetics,
       food,
       fruits,
       technical,
       textile
  FROM (SELECT branch,
               city,
               amount,
               productline
          FROM dbo.branchtotalsales) AS SourceTable
         PIVOT ( SUM(amount)
                 FOR productline IN ([chemical],
                                     [cosmetics],
                                     [food],
                                     [fruits],
                                     [technical],
                                     [textile])
			    ) AS pivottable
;

-- 2 Group amount under newly created columns per Branch and City. If there is no amount for ProductLines set it to zero, using BranchTotalSalessql from the references.

SELECT branch,
       city,
       COALESCE(SUM(chemical), 0)       AS chemical,
       COALESCE(SUM(cosmetics), 0)      AS cosmetics,
       COALESCE(SUM(food), 0)           AS food,
       COALESCE(SUM(fruits), 0)         AS fruits,
       COALESCE(SUM(technical), 0)      AS technical,
       COALESCE(SUM(textile), 0)        AS textile
  FROM (SELECT branch,
               city,
               amount,
               productline
          FROM dbo.branchtotalsales) AS SourceTable
         PIVOT ( SUM(amount)
                 FOR productline IN ([chemical],
                                     [cosmetics],
                                     [food],
                                     [fruits],
                                     [technical],
                                     [textile])
			    ) AS pivottable
GROUP BY branch, city
;

-- 3 Retrieve Branch, City, newly created ProductLine, and Amount fields transposing data into the two-dimensional dataset, using PivottedDatasql from the references.

select branch, city, productline, amount
from dbo.PivottedData
unpivot (amount for ProductLine IN (chemical,
									cosmetics,
									food,
									fruits,
									technical,
									textile)) AS UnpivitedData
;
