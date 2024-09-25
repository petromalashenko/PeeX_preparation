
-- Configuration to create memory optimized file group
ALTER DATABASE AdventureWorks2019
ADD FILEGROUP MO_FILEGROUP CONTAINS MEMORY_OPTIMIZED_DATA;
GO

ALTER DATABASE AdventureWorks2019
ADD FILE 
(
    NAME = MO_DataFile,
    FILENAME = 'C:\PeEX_Data\MO_DataFile'
)
TO FILEGROUP MO_FILEGROUP;
GO


-- Create table

IF OBJECT_ID(N'dbo.Employee', N'U') IS NOT NULL
  DROP TABLE [dbo].[Employee];
GO
-------------
CREATE TABLE dbo.Employee (
    EmployeeID INT PRIMARY KEY NONCLUSTERED,
    FirstName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    LastName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(15),
    HireDate DATETIME2,
	JobID NVARCHAR(100),
    Salary DECIMAL(10, 2),
	CommisionPCT DECIMAL(5, 2),
	ManagerID INT,
	DepartmentId INT
)
WITH (MEMORY_OPTIMIZED=ON)   
;
GO

BULK INSERT dbo.Employee
FROM 'C:\PeEX_Data\employees.csv'
WITH
(
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    ROWTERMINATOR='\n'
)
;
GO

-- Query data
select * from dbo.Employee;