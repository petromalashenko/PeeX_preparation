

-- 1 APPROX_COUNT_DISTINCT: Estimating Distinct Products Sold

SELECT DATEPART(YEAR, soh.OrderDate)        AS OrderYear,
       APPROX_COUNT_DISTINCT(sod.ProductID) AS EstimatedDistinctProducts
 FROM Sales.SalesOrderDetail sod
      INNER JOIN Sales.SalesOrderHeader soh
      	      ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY DATEPART(YEAR, soh.OrderDate)
ORDER BY OrderYear;



-- 2 GROUP BY ROLLUP: Sales by Year and Quarter
SELECT 
    YEAR(so.OrderDate) AS OrderYear,
    DATEPART(QUARTER, so.OrderDate) AS OrderQuarter,
    SUM(sod.LineTotal) AS TotalSales
FROM 
    Sales.SalesOrderHeader so
    INNER JOIN Sales.SalesOrderDetail sod
	       ON so.SalesOrderID = sod.SalesOrderID
GROUP BY ROLLUP (YEAR(so.OrderDate), DATEPART(QUARTER, so.OrderDate))
;


--3 GROUP BY CUBE: Sales by Product and Category

SELECT 
    c.Name AS CategoryName,
    p.Name AS ProductName,
    SUM(s.LineTotal) AS TotalSales
FROM 
    Sales.SalesOrderDetail s
    INNER JOIN Production.Product p
	        ON s.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory ps
	        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory c
	        ON ps.ProductCategoryID = c.ProductCategoryID
GROUP BY CUBE (c.Name, p.Name);


-- 4 GROUP BY GROUPING SETS

SELECT 
    ProductID, 
    SpecialOfferID, 
    SUM(LineTotal) AS TotalSales
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    GROUPING SETS (
        (ProductID, SpecialOfferID),   -- Group by both ProductID and SpecialOfferID
        (ProductID),                     -- Group by ProductID only
        (SpecialOfferID),              -- Group by SpecialOfferID only
        ()                                -- Overall total
    )
ORDER BY ProductID, SpecialOfferID;
