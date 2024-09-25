
-------------------------------------
-- 1 Clustered index on dbo.Product
-------------------------------------
DROP INDEX IF EXISTS IX_Product_ProductID
	ON Purchasing.ProductVendor;
GO
CREATE CLUSTERED INDEX IX_Product_ProductID ON dbo.Product (ProductID);
GO


-----------------------------------------------------
-- 2 Nonclustered index on Purchasing.ProductVendor
-----------------------------------------------------
DROP INDEX IF EXISTS IX_ProductVendor_VendorID
	ON Purchasing.ProductVendor;
GO

CREATE NONCLUSTERED INDEX IX_ProductVendor_VendorID
    ON Purchasing.ProductVendor (BusinessEntityID);
GO


-----------------------------------------------------
-- 3 Filtered index on Production.BillOfMaterials
-----------------------------------------------------
DROP INDEX IF EXISTS FI_BillOfMaterialsWithEndDate
    ON Production.BillOfMaterials
GO

CREATE NONCLUSTERED INDEX FI_BillOfMaterialsWithEndDate
    ON Production.BillOfMaterials (ComponentID, StartDate)
    WHERE EndDate IS NOT NULL ;
GO


-----------------------------------------------------
-- 4 Columnstore index on Sales.SalesPerson
-----------------------------------------------------
DROP INDEX IF EXISTS IX_SalesPerson_Columnstore
    ON Production.BillOfMaterials
GO

CREATE COLUMNSTORE INDEX IX_SalesPerson_Columnstore
ON Sales.SalesPerson (BusinessEntityID, SalesYTD, ModifiedDate);
GO

----------------------------------------------------------------
-- 5 Nonclustered index on Person.Address with included columns
----------------------------------------------------------------

CREATE NONCLUSTERED INDEX IX_Address_PostalCode  
ON Person.Address (PostalCode)  
INCLUDE (AddressLine1, AddressLine2, City, StateProvinceID);  
GO

--------------------------------------------
-- Create Materialized view (Azure Synapse)
--------------------------------------------

CREATE MATERIALIZED VIEW dbo.mvwSalesSummary
AS
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(s.Quantity)    AS TotalQuantity,
    SUM(s.TotalAmount) AS TotalSales,
    AVG(s.TotalAmount) AS AverageSales
FROM 
    Sales s
    INNER JOIN Products p
	        ON s.ProductID = p.ProductID
WHERE 
    s.SaleDate >= DATEADD(YEAR, -1, GETDATE())  -- Last year data
GROUP BY 
    p.ProductID, p.ProductName;
