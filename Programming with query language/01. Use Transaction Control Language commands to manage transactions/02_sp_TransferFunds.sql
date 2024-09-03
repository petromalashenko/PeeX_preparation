
DROP PROCEDURE IF EXISTS [dbo].[sp_TransferFunds];
GO

CREATE PROCEDURE dbo.sp_TransferFunds
    @FromAccountNumber INT,
    @ToAccountNumber INT,
    @TransferAmount DECIMAL(18, 2),
    @MaxTransferAmount DECIMAL(18, 2) = 10000.00,  -- Configurable maximum transfer amount
    @MaxRetryAttempts INT = 3  -- Configurable maximum number of retry attempts
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RetryCount INT = 0;
    DECLARE @TransactionId UNIQUEIDENTIFIER = NEWID();
    DECLARE @Success BIT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000) = NULL;
    
    WHILE @RetryCount <= @MaxRetryAttempts
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;
            
            -- Check if the transfer amount exceeds the maximum allowed amount
            IF @TransferAmount > @MaxTransferAmount
            BEGIN
                SET @ErrorMessage = 'Transfer amount exceeds the maximum allowed limit.';
                THROW 50000, @ErrorMessage, 1;
            END

            -- Perform the transfer
            -- Withdraw from the source account
            UPDATE dbo.BankAccounts
            SET Balance = Balance - @TransferAmount,
			    LastUpdateTimestamp = CURRENT_TIMESTAMP
            WHERE AccountNumber = @FromAccountNumber;
            
            -- Check if the source account has sufficient balance
            IF @@ROWCOUNT = 0 OR (SELECT Balance FROM dbo.BankAccounts WHERE AccountNumber = @FromAccountNumber) < @TransferAmount
            BEGIN
                SET @ErrorMessage = 'Insufficient balance or source account does not exist.';
                THROW 50000, @ErrorMessage, 1;
            END
            
            -- Deposit into the destination account
            UPDATE dbo.BankAccounts
            SET Balance = Balance + @TransferAmount,
			    LastUpdateTimestamp = CURRENT_TIMESTAMP
            WHERE AccountNumber = @ToAccountNumber;
            
            -- Check if the destination account exists
            IF @@ROWCOUNT = 0
            BEGIN
                SET @ErrorMessage = 'Destination account does not exist.';
                THROW 50000, @ErrorMessage, 1;
            END
            
            -- Commit the transaction if everything is successful
            COMMIT TRANSACTION;
            SET @Success = 1;
            BREAK;  -- Exit the retry loop
        END TRY
        BEGIN CATCH
            -- Rollback the transaction in case of error
            ROLLBACK TRANSACTION;
            
            -- Capture the error message
            SET @ErrorMessage = ERROR_MESSAGE();
            
            -- Log the error for audit
            INSERT INTO dbo.TransferAudit (TransactionId, FromAccount, ToAccount, Amount, Result, ErrorMessage, LogDate)
            VALUES (@TransactionId, @FromAccountNumber, @ToAccountNumber, @TransferAmount, 'Failed', @ErrorMessage, GETDATE());
            
            -- Retry logic for deadlocks
            IF ERROR_NUMBER() IN (1205)  -- Deadlock error number
            BEGIN
                SET @RetryCount = @RetryCount + 1;
                WAITFOR DELAY '00:00:05';  -- Wait for 5 seconds before retrying
            END
            ELSE
            BEGIN
                -- For other errors, rethrow the error
                THROW;
            END
        END CATCH
    END
    
    -- If maximum retry attempts are exceeded, log the final failure
    IF @Success = 0
    BEGIN
        INSERT INTO dbo.TransferAudit (TransactionId, FromAccount, ToAccount, Amount, Result, ErrorMessage, LogDate)
        VALUES (@TransactionId, @FromAccountNumber, @ToAccountNumber, @TransferAmount, 'Failed', 'Exceeded maximum retry attempts.', GETDATE());
    END
    ELSE
    BEGIN
        -- Log successful transfer
        INSERT INTO dbo.TransferAudit (TransactionId, FromAccount, ToAccount, Amount, Result, ErrorMessage, LogDate)
        VALUES (@TransactionId, @FromAccountNumber, @ToAccountNumber, @TransferAmount, 'Success', NULL, GETDATE());
    END
END
