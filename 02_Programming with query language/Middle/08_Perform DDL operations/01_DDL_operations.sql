
-- Default constraint
ALTER TABLE Production.Product ADD  CONSTRAINT DF_Product_ModifiedDate  DEFAULT (getdate()) FOR ModifiedDate;
GO

-- Check constraint
ALTER TABLE Production.Product WITH CHECK ADD CONSTRAINT CK_Product_ListPrice CHECK (ListPrice>=(0.00));
GO

-- Unique constraint
ALTER TABLE Production.Product WITH CHECK ADD CONSTRAINT UQ_ProductNumber UNIQUE (ProductNumber);
GO

-- Extend volume of Weight column
ALTER TABLE Production.Product ALTER COLUMN Weight DECIMAL(10,2) NULL;
GO
