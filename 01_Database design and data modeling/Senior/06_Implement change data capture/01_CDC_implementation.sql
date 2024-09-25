
USE AdventureWorks2019;
GO

-- Enable CDC on Database level
EXEC sys.sp_cdc_enable_db;


EXEC sys.sp_cdc_enable_table
    @source_schema = N'Sales',
    @source_name = N'SalesOrderHeader',
    @role_name = NULL; -- Set a role if needed
;

-- Check CDC table
SELECT *
FROM cdc.change_tables;


-- Insert a new sales order
INSERT INTO Sales.SalesOrderHeader (CustomerID, OrderDate, TotalDue)
VALUES (1, GETDATE(), 100.00);

-- Update a sales order
UPDATE Sales.SalesOrderHeader
SET TotalDue = 150.00
WHERE SalesOrderID = 1;

-- Delete a sales order
DELETE FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 1;


------------------------
-- Query CDC Data
------------------------
DECLARE @from_lsn binary(10), @to_lsn binary(10);

-- Get the latest LSN for the current transaction
SET @from_lsn = (SELECT MIN(ValidFrom) FROM cdc.fn_cdc_get_all_changes_SalesOrderHeader(NULL, NULL, NULL));
SET @to_lsn = sys.fn_cdc_get_max_lsn();

SELECT *
FROM cdc.fn_cdc_get_all_changes_SalesOrderHeader(@from_lsn, @to_lsn, 'all');


-- Clean Up CDC Data
EXEC sys.sp_cdc_cleanup_change_table
    @name = N'Sales.SalesOrderHeader',
    @low_water_mark = @low_water_mark; -- Specify a low watermark as needed


-- Disable CDC (if needed)
EXEC sys.sp_cdc_disable_table
    @source_schema = N'Sales',
    @source_name = N'SalesOrderHeader',
    @capture_instance = N'SalesOrderHeader';


-- Disable CDC at the database level
EXEC sys.sp_cdc_disable_db;