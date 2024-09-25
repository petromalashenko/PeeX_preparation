
begin tran

update [dbo].[BankAccounts]
set balance = balance - 0
WHERE  accountnumber IN ( 100000);

WAITFOR DELAY '00:00:10';

update [dbo].[BankAccounts]
set balance = balance - 0
WHERE  accountnumber IN ( 100001);

commit;
