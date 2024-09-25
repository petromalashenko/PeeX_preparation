IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL
  DROP TABLE dbo.Orders;
GO
CREATE TABLE dbo.Orders 

     ( 

      OrderId int  , 

      orderDate date, 

      ShipDate datetime2(7), 

      paymentDate nvarchar(10), 

      orderPlacedOn datetime2(7), 

      orderPlacedOnTimeOffset datetime2(7) 

     )
;
GO

INSERT INTO dbo.Orders (OrderId, orderDate, ShipDate, paymentDate, orderPlacedOn, orderPlacedOnTimeOffset ) 

VALUES 

(1,'2022-01-01 02:05:21', '20220203', '20230103', '2022-01-01 16:05:21.9375884', '2022-01-01 16:05:21.9375884 +02:00' ), 

(2,'2022-01-01 03:25:21', '20220104', '20220104', '2022-01-01 12:05:21.9375884', '2022-01-01 12:05:21.9375884 +02:00' ), 

(3,'2022-01-01 02:05:18', '20220105', '20220101', '2022-01-01 08:05:21.9375884', '2022-01-01 08:05:21.9375884 +02:00' ), 

(4,'2022-01-01 14:09:28', '20220405', '20220102', '2022-01-01 07:05:21.9375884', '2022-01-01 07:05:21.9375884 +02:00' ), 

(5,'2022-01-01 16:05:21', '20230107', '20230102', '2022-01-01 16:04:21.9375884', '2022-01-01 16:04:21.9375884 +02:00' ), 

(6,'2022-01-01 11:35:21', '20220105', '20220108a', '2022-01-01 16:02:21.9375884', '2022-01-01 16:02:21.9375884 +02:00'), 

(7,'2023-01-01 02:05:21', '20230203', '20230103', '2023-01-01 16:05:21.9375884', '2023-01-01 16:05:21.9375884 +02:00' ), 

(8,'2023-01-01 03:25:21', '20230104', '20230104', '2023-01-01 12:05:21.9375884', '2023-01-01 12:05:21.9375884 +02:00' ), 

(9,'2023-01-01 02:05:18', '20230105', '20230101', '2023-01-01 08:05:21.9375884', '2023-01-01 08:05:21.9375884 +02:00' ), 

(10,'2023-01-01 14:09:28', '20230405', '20230102', '2023-01-01 07:05:21.9375884', '2023-01-01 07:05:21.9375884 +02:00' ), 

(11,'2023-01-01 16:05:21', '20230107', '20230102', '2023-01-01 16:04:21.9375884', '2023-01-01 16:04:21.9375884 +02:00' ), 

(12,'2023-01-01 11:35:21', '20230105', '20230108a', '2023-01-01 16:02:21.9375884', '2023-01-01 16:02:21.9375884 +02:0'), 

(13,'2023-03-01 02:05:21', '20230303', '20240303', '2023-03-01 16:05:21.9375884', '2023-03-01 16:05:21.9375884 +02:00'), 

(14,'2023-03-01 03:25:21', '20230304', '20230304', '2023-03-01 12:05:21.9375884', '2023-03-01 12:05:21.9375884 +02:00'), 

(15,'2023-03-01 02:05:18', '20230305', '20230301', '2023-03-01 08:05:21.9375884', '2023-03-01 08:05:21.9375884 +02:00'), 

(16,'2023-03-01 14:09:28', '20230305', '20230302', '2023-03-01 07:05:21.9375884', '2023-03-01 07:05:21.9375884 +02:00'), 

(17,'2023-03-01 16:05:21', '20230307', '20230302', '2023-03-01 16:04:21.9375884', '2023-03-01 16:04:21.9375884 +02:00'), 

(18,'2023-03-01 11:35:21', '20230305', '20230308a', '2023-03-01 16:02:21.9375884', '2023-03-01 16:02:21.9375884 +02:00') 
;
GO
----------------------------------------
-- TASKS RESOLUTION
----------------------------------------

-- 1 Date parts and date parts names. 

SELECT orderid,
       orderdate,
       DATEPART(year, orderdate)  AS OrderYear,
       DATEPART(month, orderdate) AS OrderMonth,
       DATEPART(day, orderdate)   AS OrderDay,
       DATEPART(week, orderdate)  AS OrderWeek
FROM   dbo.orders
;


-- 2 A column named shippedAfterDays that represents the difference between orderdate and shipdate with days and outputs only the orders where the difference is more or equal to 30 days. Represent date difference in days using the DATEDIFF function.


SELECT orderid,
       orderdate,
	   shipdate,
	   DATEDIFF(DAY, orderdate, shipdate) AS shippedAfterDays
  FROM dbo.orders
WHERE DATEDIFF(DAY, orderdate, shipdate) >= 30
;


-- 3 Orders that occurred in March regardless of year.

SELECT orderid,
       orderdate,
	   shipdate,
	   paymentDate
  FROM dbo.orders
WHERE DATEPART(MONTH, orderDate) = 3
;

-- 4 Orders where paymentdate cannot be convertible to date.

SELECT orderid,
       orderdate,
	   shipdate,
	   paymentdate
  FROM dbo.orders
WHERE TRY_CONVERT(date, paymentDate) IS NULL
;


-- 5 Orders where the year of shipdate and payment date is different regardless of incorrect paymentdate type.

SELECT orderid,
       orderdate,
	   shipdate,
	   paymentdate,
	   DATEPART(YEAR, shipdate)                         AS shipyear,
       DATEPART(YEAR, TRY_CONVERT(date, paymentdate))   AS paymentyear
  FROM dbo.orders
 WHERE DATEPART(YEAR, shipdate) != DATEPART(YEAR, TRY_CONVERT(date, paymentdate))
;
