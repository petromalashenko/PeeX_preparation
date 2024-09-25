IF OBJECT_ID(N'dbo.MarketSales', N'U') IS NOT NULL
  DROP TABLE dbo.MarketSales;
GO
CREATE TABLE 

   dbo.MarketSales 

    ( 

    InvoiceId INT IDENTITY(1,1) , 

    Branch VARCHAR(10), 

    City VARCHAR(99),   

    Customertype VARCHAR(20),   

    Gender VARCHAR(10), 

    Productline VARCHAR(99), 

    Unitprice NUMERIC (14,4),   

    Quantity NUMERIC (14,4) , 

    Payment VARCHAR(99) );
GO

INSERT INTO  dbo.MarketSales 

( 

     Branch         

    ,City           

    ,Customertype   

    ,Gender     

    ,Productline 

    ,Unitprice   

    ,Quantity    

    ,Payment     

) 

SELECT * FROM (VALUES 

('A','Yangon','Member','Female','Health and beauty','74.69','7','Ewallet'), 

('C','Naypyitaw','Normal','Female','Electronic accessories','15.28','5','Cash'), 

('A','Yangon','Normal','Male','Home and lifestyle','46.33','7','Credit card'), 

('A','Yangon','Member','Male','Health and beauty','58.22','8','Ewallet'), 

('A','Yangon','Normal','Male','Sports and travel','86.31','7','Ewallet'), 

('C','Naypyitaw','Normal','Male','Electronic accessories','85.39','7','Ewallet'), 

('A','Yangon','Member','Female','Electronic accessories','68.84','6','Ewallet'), 

('C','Naypyitaw','Normal','Female','Home and lifestyle','73.56','10','Ewallet'), 

('A','Yangon','Member','Female','Health and beauty','36.26','2','Credit card'), 

('B','Mandalay','Member','Female','Food and beverages','54.84','3','Credit card'), 

('B','Mandalay','Member','Female','Fashion accessories','14.48','4','Ewallet'), 

('B','Mandalay','Member','Male','Electronic accessories','25.51','4','Cash'), 

('A','Yangon','Normal','Female','Electronic accessories','46.95','5','Ewallet'), 

('A','Yangon','Normal','Male','Food and beverages','43.19','10','Ewallet'), 

('A','Yangon','Normal','Female','Health and beauty','71.38','10','Cash'), 

('B','Mandalay','Member','Female','Sports and travel','93.72','6','Cash'), 

('A','Yangon','Member','Female','Health and beauty','68.93','7','Credit card'), 

('A','Yangon','Normal','Male','Sports and travel','72.61','6','Credit card'), 

('A','Yangon','Normal','Male','Food and beverages','54.67','3','Credit card'), 

('B','Mandalay','Normal','Female','Home and lifestyle','40.3','2','Ewallet'), 

('C','Naypyitaw','Member','Male','Electronic accessories','86.04','5','Ewallet'), 

('B','Mandalay','Normal','Male','Health and beauty','87.98','3','Ewallet'), 

('B','Mandalay','Normal','Male','Home and lifestyle','33.2','2','Credit card'), 

('A','Yangon','Normal','Male','Electronic accessories','34.56','5','Ewallet'), 

('A','Yangon','Member','Male','Sports and travel','88.63','3','Ewallet'), 

('A','Yangon','Member','Female','Home and lifestyle','52.59','8','Credit card'), 

('B','Mandalay','Normal','Male','Fashion accessories','33.52','1','Cash'), 

('A','Yangon','Normal','Female','Fashion accessories','87.67','2','Credit card'), 

('B','Mandalay','Normal','Female','Food and beverages','88.36','5','Cash'), 

('A','Yangon','Normal','Male','Health and beauty','24.89','9','Cash'), 

('B','Mandalay','Normal','Male','Fashion accessories','94.13','5','Credit card'), 

('B','Mandalay','Member','Male','Sports and travel','78.07','9','Cash'), 

('B','Mandalay','Normal','Male','Sports and travel','83.78','8','Cash'), 

('A','Yangon','Normal','Male','Health and beauty','96.58','2','Credit card'), 

('C','Naypyitaw','Member','Female','Food and beverages','99.42','4','Ewallet'), 

('C','Naypyitaw','Member','Female','Sports and travel','68.12','1','Ewallet'), 

('A','Yangon','Member','Male','Sports and travel','62.62','5','Ewallet'), 

('A','Yangon','Normal','Female','Electronic accessories','60.88','9','Ewallet'), 

('C','Naypyitaw','Normal','Female','Health and beauty','54.92','8','Ewallet'), 

('B','Mandalay','Member','Male','Home and lifestyle','30.12','8','Cash'), 

('B','Mandalay','Member','Female','Home and lifestyle','86.72','1','Ewallet'), 

('C','Naypyitaw','Member','Male','Home and lifestyle','56.11','2','Cash'), 

('B','Mandalay','Member','Female','Sports and travel','69.12','6','Cash'), 

('C','Naypyitaw','Member','Female','Food and beverages','98.7','8','Cash'), 

('C','Naypyitaw','Member','Male','Health and beauty','15.37','2','Cash'), 

('B','Mandalay','Member','Female','Electronic accessories','93.96','4','Cash'), 

('B','Mandalay','Member','Male','Health and beauty','56.69','9','Credit card'), 

('B','Mandalay','Member','Female','Food and beverages','20.01','9','Ewallet'), 

('B','Mandalay','Member','Male','Electronic accessories','18.93','6','Credit card'), 

('C','Naypyitaw','Member','Female','Fashion accessories','82.63','10','Ewallet'), 

('C','Naypyitaw','Member','Male','Food and beverages','91.4','7','Cash'), 

('A','Yangon','Member','Female','Food and beverages','44.59','5','Cash'), 

('B','Mandalay','Member','Female','Fashion accessories','17.87','4','Ewallet'), 

('C','Naypyitaw','Member','Male','Fashion accessories','15.43','1','Credit card'), 

('B','Mandalay','Normal','Male','Home and lifestyle','16.16','2','Ewallet'), 

('C','Naypyitaw','Normal','Female','Electronic accessories','85.98','8','Cash'), 

('A','Yangon','Member','Male','Home and lifestyle','44.34','2','Cash'), 

('A','Yangon','Normal','Male','Health and beauty','89.6','8','Ewallet'), 

('A','Yangon','Member','Female','Home and lifestyle','72.35','10','Cash'), 

('C','Naypyitaw','Normal','Male','Electronic accessories','30.61','6','Cash'), 

('C','Naypyitaw','Member','Female','Sports and travel','24.74','3','Credit card'), 

('C','Naypyitaw','Normal','Male','Home and lifestyle','55.73','6','Ewallet'), 

('B','Mandalay','Member','Female','Sports and travel','55.07','9','Ewallet'), 

('A','Yangon','Member','Male','Sports and travel','15.81','10','Credit card'), 

('B','Mandalay','Member','Male','Health and beauty','75.74','4','Cash'), 

('A','Yangon','Member','Male','Health and beauty','15.87','10','Cash'), 

('C','Naypyitaw','Normal','Female','Health and beauty','33.47','2','Ewallet'), 

('B','Mandalay','Member','Female','Fashion accessories','97.61','6','Ewallet'), 

('A','Yangon','Normal','Male','Sports and travel','78.77','10','Cash'), 

('A','Yangon','Member','Female','Health and beauty','18.33','1','Cash'), 

('C','Naypyitaw','Normal','Male','Food and beverages','89.48','10','Credit card'), 

('C','Naypyitaw','Normal','Male','Fashion accessories','62.12','10','Cash'), 

('B','Mandalay','Member','Female','Food and beverages','48.52','3','Ewallet'), 

('C','Naypyitaw','Normal','Female','Electronic accessories','75.91','6','Cash'), 

('A','Yangon','Normal','Male','Home and lifestyle','74.67','9','Ewallet'), 

('C','Naypyitaw','Normal','Female','Electronic accessories','41.65','10','Credit card'), 

('C','Naypyitaw','Member','Male','Fashion accessories','49.04','9','Credit card'), 

('A','Yangon','Member','Female','Fashion accessories','20.01','9','Credit card'), 

('C','Naypyitaw','Member','Female','Food and beverages','78.31','10','Ewallet'), 

('C','Naypyitaw','Normal','Female','Health and beauty','20.38','5','Cash'), 

('C','Naypyitaw','Normal','Female','Health and beauty','99.19','6','Credit card'), 

('B','Mandalay','Normal','Female','Food and beverages','96.68','3','Ewallet'), 

('C','Naypyitaw','Normal','Male','Food and beverages','19.25','8','Ewallet'), 

('C','Naypyitaw','Member','Female','Food and beverages','80.36','4','Credit card'), 

('C','Naypyitaw','Member','Male','Sports and travel','48.91','5','Cash'), 

('C','Naypyitaw','Normal','Female','Sports and travel','83.06','7','Ewallet'), 

('C','Naypyitaw','Normal','Male','Fashion accessories','76.52','5','Cash'), 

('A','Yangon','Member','Male','Food and beverages','49.38','7','Credit card'), 

('A','Yangon','Normal','Male','Sports and travel','42.47','1','Cash'), 

('B','Mandalay','Normal','Female','Health and beauty','76.99','6','Cash'), 

('C','Naypyitaw','Member','Female','Home and lifestyle','47.38','4','Cash'), 

('C','Naypyitaw','Normal','Female','Sports and travel','44.86','10','Ewallet'), 

('A','Yangon','Member','Female','Sports and travel','21.98','7','Ewallet'), 

('B','Mandalay','Member','Male','Health and beauty','64.36','9','Credit card'), 

('C','Naypyitaw','Normal','Male','Health and beauty','89.75','1','Credit card'), 

('A','Yangon','Normal','Male','Electronic accessories','97.16','1','Ewallet'), 

('B','Mandalay','Normal','Male','Health and beauty','87.87','10','Ewallet'), 

('C','Naypyitaw','Normal','Female','Electronic accessories','12.45','6','Cash'), 

('A','Yangon','Normal','Male','Food and beverages','52.75','3','Ewallet'), 

('B','Mandalay','Normal','Male','Home and lifestyle','82.7','6','Cash') 

) 
AS A (  Branch, City,   Customertype,   Gender, Productline,    Unitprice,  Quantity    ,Payment)
;
GO

-------------------------------------
-- TASKS RESOLUTION
-------------------------------------

-- 1 Quantity from the previous row.

SELECT invoiceid,
       branch,
       city,
       customertype,
       gender,
       productline,
       quantity,
       LAG(quantity) OVER (ORDER BY invoiceid) AS quantity_1_back
  FROM dbo.marketsales
;


-- 2 Quantity from a row that is two positions back.

SELECT invoiceid,
       branch,
       city,
       customertype,
       gender,
       productline,
       quantity,
       LAG(quantity, 2) OVER (ORDER BY invoiceid) AS quantity_2_back
  FROM dbo.marketsales
;

-- 3 Quantity from the next row.

SELECT invoiceid,
       branch,
       city,
       customertype,
       gender,
       productline,
       quantity,
       LEAD(quantity) OVER (ORDER BY invoiceid) AS quantity_1_forward
  FROM dbo.marketsales
;

-- 4 Quantity from a row that is two positions ahead.

SELECT invoiceid,
       branch,
       city,
       customertype,
       gender,
       productline,
       quantity,
       LEAD(quantity, 2) OVER (ORDER BY invoiceid) AS quantity_2_forward
  FROM dbo.marketsales
;

-- 5 Quantity from the first value in an ordered set of values.

SELECT invoiceid,
       branch,
       city,
       customertype,
       gender,
       productline,
       quantity,
       FIRST_VALUE(quantity) OVER (ORDER BY branch, city, productline) AS quantity_fists
  FROM dbo.marketsales
ORDER BY branch, city, productline
;

-- 6 Quantity from the last value in an ordered set of values.

SELECT invoiceid,
       branch,
       city,
       customertype,
       gender,
       productline,
       quantity,
       LAST_VALUE(quantity) OVER (ORDER BY branch, city, productline) AS quantity_last
  FROM dbo.marketsales
ORDER BY branch, city, productline
;