IF OBJECT_ID(N'dbo.Employee', N'U') IS NOT NULL
  DROP TABLE [dbo].[Employee];
GO
-------------

CREATE TABLE dbo.Employee (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    LastName NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Email NVARCHAR(100) MASKED WITH (FUNCTION = 'partial(1,"XXXX",2)'),
    PhoneNumber NVARCHAR(15) SPARSE,
    HireDate DATETIME2,
	JobID NVARCHAR(100),
    Salary DECIMAL(10, 2),
	CommisionPCT DECIMAL(5, 2),
	ManagerID INT,
	DepartmentId INT
)
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

-- Calculated column
ALTER TABLE dbo.Employee ADD SalaryExcludingTax AS (Salary/1.2) PERSISTED;


-- Query data
select * from dbo.Employee;
