-- Check data distribution by years
select datepart(year, orderdate), count(*)
from [Sales].[SalesOrderHeader]
group by datepart(year, orderdate)
order by datepart(year, orderdate)
;

-- Create filegroups for partitions
ALTER DATABASE AdventureWorks2019
ADD FILEGROUP SalesHeader_fg1;
GO
--
ALTER DATABASE AdventureWorks2019
ADD FILEGROUP SalesHeader_fg2;
GO
--
ALTER DATABASE AdventureWorks2019
ADD FILEGROUP SalesHeader_fg3;
GO
--
ALTER DATABASE AdventureWorks2019
ADD FILE 
(
    NAME = SalesHeader_fg1,
    FILENAME = 'C:\PeEX_Data\SalesHeader_FG\SalesHeader_fg1'
)
TO FILEGROUP SalesHeader_fg1;
GO
--
ALTER DATABASE AdventureWorks2019
ADD FILE 
(
    NAME = SalesHeader_fg2,
    FILENAME = 'C:\PeEX_Data\SalesHeader_FG\SalesHeader_fg2'
)
TO FILEGROUP SalesHeader_fg2;
GO
--
ALTER DATABASE AdventureWorks2019
ADD FILE 
(
    NAME = SalesHeader_fg3,
    FILENAME = 'C:\PeEX_Data\SalesHeader_FG\SalesHeader_fg3'
)
TO FILEGROUP SalesHeader_fg3;
GO
--


-- Create partition function
--DROP PARTITION FUNCTION [pf_SalesOrdHeader_byOrderDate];
GO
--
CREATE PARTITION FUNCTION [pf_SalesOrdHeader_byOrderDate] (datetime)
AS RANGE RIGHT FOR VALUES (N'2013-01-01T00:00:00', N'2014-01-01T00:00:00')
;
GO
--

-- Create partition schema
--DROP PARTITION SCHEME [ps_SalesOrdHeader_byYear];
GO
CREATE PARTITION SCHEME [ps_SalesOrdHeader_byYear] AS PARTITION [pf_SalesOrdHeader_byOrderDate]
TO ([SalesHeader_fg1] , [SalesHeader_fg2] , [SalesHeader_fg3])
;
GO

-- Change existin PK constaraint to nonclustered
ALTER TABLE [Sales].[SalesOrderHeaderSalesReason]  DROP CONSTRAINT [FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID];
GO
ALTER TABLE [Sales].[SalesOrderDetail] DROP CONSTRAINT [FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID];
GO
ALTER TABLE [Sales].[SalesOrderHeader] DROP CONSTRAINT [PK_SalesOrderHeader_SalesOrderID];
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [PK_SalesOrderHeader_SalesOrderID] PRIMARY KEY NONCLUSTERED ([SalesOrderID]);
GO


ALTER TABLE [Sales].[SalesOrderHeaderSalesReason]  WITH CHECK ADD  CONSTRAINT [FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID] FOREIGN KEY([SalesOrderID])
REFERENCES [Sales].[SalesOrderHeader] ([SalesOrderID])
ON DELETE CASCADE
GO
ALTER TABLE [Sales].[SalesOrderHeaderSalesReason] CHECK CONSTRAINT [FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID]
GO

ALTER TABLE [Sales].[SalesOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID] FOREIGN KEY([SalesOrderID])
REFERENCES [Sales].[SalesOrderHeader] ([SalesOrderID])
ON DELETE CASCADE
GO
ALTER TABLE [Sales].[SalesOrderDetail] CHECK CONSTRAINT [FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID]
GO


-- Partition table using clustered index
--DROP INDEX [CI_SalesOrdHeader_byYear] ON [Sales].[SalesOrderHeader];
GO
CREATE CLUSTERED INDEX [CI_SalesOrdHeader_byYear] ON [Sales].[SalesOrderHeader]
(
 [OrderDate]
 ) WITH ( SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF , ONLINE = OFF) ON [ps_SalesOrdHeader_byYear]([OrderDate])
;
GO


-- Check partition distribution
SELECT OBJECT_SCHEMA_NAME (t. object_id) AS schema_name        
      ,t.name AS table_name        
      ,i.index_id        
      ,i.name AS index_name        
      ,p.partition_number        
      ,p.rows          
FROM sys.tables t             
     join sys.indexes i ON t.object_id = i.object_id 
     join sys.partitions p ON i.object_id=p.object_id AND i.index_id = p.index_id
WHERE i.name = 'CI_SalesOrdHeader_byYear'
;

