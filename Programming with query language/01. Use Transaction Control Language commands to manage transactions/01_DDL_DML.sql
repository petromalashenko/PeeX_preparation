---------------------------
-- [dbo].[BankAccounts]
---------------------------
IF OBJECT_ID(N'dbo.BankAccounts', N'U') IS NOT NULL
  DROP TABLE [dbo].[BankAccounts];

GO

CREATE TABLE [dbo].[BankAccounts]
  (
     AccountNumber       INT NOT NULL,
     Balance             DECIMAL(18, 2),
     LastUpdateTimestamp DATETIME,
     CONSTRAINT pk_bankaccounts PRIMARY KEY (AccountNumber)
  );

GO

DECLARE @startnum INT= 100000;
DECLARE @endnum INT=199999;
DECLARE @LastUpdateTimestamp DATETIME=CURRENT_TIMESTAMP

WHILE @startnum <= @endnum
  BEGIN
      INSERT INTO [dbo].[BankAccounts]
      SELECT @startnum,
             Rand() * ( -110000 ) + 100000 AS Balance,
             -- random number in range -10000 and 100000
             @LastUpdateTimestamp          AS LastUpdateTimestamp

      SET @startnum = @startnum + 1
  END;

GO

---------------------------
-- [dbo].[TransferAudit]
---------------------------
IF OBJECT_ID(N'dbo.TransferAudit', N'U') IS NOT NULL
  DROP TABLE [dbo].[TransferAudit];

GO

CREATE TABLE [dbo].[TransferAudit]
  (
     TransactionId UNIQUEIDENTIFIER NOT NULL,
     FromAccount   INTEGER NOT NULL,
     ToAccount     INTEGER NOT NULL,
     Amount        DECIMAL(18, 2) NOT NULL,
     Result        NVARCHAR(100),
     ErrorMessage  NVARCHAR(4000),
     LogDate       DATETIME,
     CONSTRAINT pk_transferaudit PRIMARY KEY (TransactionId)
  );

GO 