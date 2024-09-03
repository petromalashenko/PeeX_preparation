
-------------------------------------------------------------
-- CASE 1: Successfully move 1096.48 from 100000 to 100001
-------------------------------------------------------------
-- Check Balance
SELECT *
FROM   [dbo].[BankAccounts]
WHERE  accountnumber IN ( 100000, 100001 );

-- Log
SELECT *
FROM   [dbo].[TransferAudit];


-- Initialize Funds Move
EXEC [dbo].[Sp_transferfunds]
  @FromAccountNumber = 100000,
  @ToAccountNumber = 100001,
  @TransferAmount = 1096.48; 