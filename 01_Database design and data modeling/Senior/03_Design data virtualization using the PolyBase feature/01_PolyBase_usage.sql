
-- Enable PolyBase
EXEC sp_configure @configname = 'polybase enabled', @configvalue = 1; RECONFIGURE


-- Create data source
CREATE EXTERNAL DATA SOURCE CustomerSource
WITH (
    TYPE = HADOOP,
    LOCATION = 'C:\PeEX_Data\'
);


-- Create file format
CREATE EXTERNAL FILE FORMAT CsvFormat
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    STRING_DELIMITER = '"',
    FIELD_TERMINATOR = ',',
    HEADER_ROW_COUNT = 1
);


CREATE EXTERNAL TABLE dbo.Customer (
    Index                  INT,
	CustomerId             INT,
	FirstName              NVARCHAR(100),
	LastName               NVARCHAR(100),
	Company                NVARCHAR(100),
	City                   NVARCHAR(100),
	Country                NVARCHAR(100),
	Phone1                 NVARCHAR(100),
	Phone2                 NVARCHAR(100),
	Email                  NVARCHAR(100),
	SubscriptionDate       DATE,
	Website                NVARCHAR(200)
)
WITH (
    LOCATION = 'customers.csv',
    DATA_SOURCE = CustomerSource,
    FILE_FORMAT = CsvFormat
);