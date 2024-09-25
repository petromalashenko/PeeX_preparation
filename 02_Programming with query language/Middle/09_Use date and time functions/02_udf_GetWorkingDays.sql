DROP FUNCTION IF EXISTS dbo.ufnGetWorkingDays;
GO
CREATE FUNCTION dbo.ufnGetWorkingDays
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @WorkingDays INT;

    -- Initialize the working days count
    SET @WorkingDays = 0;

    -- Ensure the StartDate is less than or equal to EndDate
    IF @StartDate > @EndDate
    BEGIN
        RETURN 0;
    END;

    -- Count the number of working days
    WITH DateRange AS (
        SELECT 
            @StartDate AS CurrentDate
        UNION ALL
        SELECT 
            DATEADD(DAY, 1, CurrentDate)
        FROM 
            DateRange
        WHERE 
            DATEADD(DAY, 1, CurrentDate) <= @EndDate
    )
    SELECT @WorkingDays = COUNT(*)
    FROM DateRange
    WHERE 
        DATENAME(WEEKDAY, CurrentDate) NOT IN ('Saturday', 'Sunday');

    RETURN @WorkingDays;
END;
GO


------------------
-- Query data 
------------------

select dbo.ufnGetWorkingDays('2024-09-01', '2024-09-23');
