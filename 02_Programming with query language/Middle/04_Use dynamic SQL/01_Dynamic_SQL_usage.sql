CREATE PROCEDURE dbo.sp_upload_files @in_FileName VARCHAR(100) = NULL
AS
BEGIN

exec sp_configure 'show advanced options', 1;
reconfigure;
exec sp_configure 'xp_cmdshell', 1;
reconfigure;

SET NOCOUNT ON;
SET IDENTITY_INSERT [log].[File_Upload] ON;
------------------------------------------------------
DECLARE @filePath varchar(200) = 'C:\Data\Datamine\',
        @fileName varchar(100),
        @fullFileName varchar(300),
		@stgTableName varchar(100),
		@tmpTableName varchar(100),
		@mainTableName varchar(100),
		@sqlColumnsList varchar(max) = '',
		@sqlColumnsListToCreate varchar(max) = '',
		@sqlCheckRules varchar(max) = '',
		@sqlInsertSTG varchar(max) = '',
		@sqlIngest varchar(max),
		@sqlInsertErrorLog varchar(max) = '',
		@sqlSuccessMsg SYSNAME,
		@sqlMoveFiles varchar(max),
		@uploadID INT,
		@isFileExist INT
------------------------------------------------------
-- Insert into log table start of the process


-- 1. Create temp table with filenames enabled to upload
-------------------------------------------------------
exec master..xp_cmdshell 'ECHO :: > E:\batch\mv_files.bat'
exec master..xp_cmdshell 'ECHO "" > E:\CheckFiles\RunStatus.txt'

IF OBJECT_ID('TEMPDB..#TMP_FILENAMES') IS NOT NULL DROP TABLE #TMP_FILENAMES;

SELECT CAST(NULL AS VARCHAR) AS File_Name INTO #TMP_FILENAMES;
DELETE FROM #TMP_FILENAMES;

IF @in_FileName IS NOT NULL
   BEGIN   
      SELECT @in_FileName AS File_Name
      INSERT INTO #TMP_FILENAMES(File_Name) VALUES(@in_FileName);
   END
ELSE
   BEGIN
      INSERT INTO #TMP_FILENAMES(File_Name)
	  SELECT File_Name
      FROM [LandZone].[cfg].[UploadConfig]
      WHERE Enabled = 1;
   END
;

------------------------------------------------------
-- 2. Iterate through the files and BULK INSERT into temp tables

WHILE EXISTS(SELECT File_Name FROM #TMP_FILENAMES)
BEGIN

   SELECT @uploadID = MAX(ID) + 1 FROM [LandZone].[log].[File_Upload];
   SET @fileName = (SELECT TOP 1 File_Name FROM #TMP_FILENAMES);
   SET @fullFileName = @filePath + @fileName;
   EXEC master.dbo.xp_fileexist @fullFileName, @isFileExist OUTPUT

   IF @isFileExist = 1
   BEGIN
     
      SET @stgTableName = 'Upload_' + REPLACE(@fileName, '.csv', '');

	  -- inconsistency between filenames and tablenames
	  IF @fileName = 'Underwater_berms.csv'
	    SET @stgTableName = 'Upload_Underwater_Berm';
	  IF @fileName = 'OpenEnding.csv'
	    SET @stgTableName = 'Upload_Open_Ending';
      --
      SET @tmpTableName = 'tmp_' + @stgTableName;
	  SET @sqlColumnsList = '';
	  SET @sqlColumnsListToCreate = '';
	  SET @sqlCheckRules = '';
	  SET @sqlInsertSTG = '';
	  SET @sqlIngest = '';
	  SET @sqlInsertErrorLog = '';

      SELECT @sqlColumnsList = @sqlColumnsList + '[' + COALESCE(cm.SourceColumn, c.column_name) + '],' 
        FROM INFORMATION_SCHEMA.COLUMNS c
		     LEFT JOIN cfg.ColumnMapping cm
			        ON c.table_name = cm.TargetTable
				   AND c.column_name = cm.TargetColumn
       WHERE c.table_name = @stgTableName
	     AND c.column_name != 'Upload_ID'
		 AND cm.Ignore IS NULL
	   ORDER BY c.ORDINAL_POSITION;

	  -- remove the last ','
	  SET @sqlColumnsList = STUFF(@sqlColumnsList, LEN(@sqlColumnsList), 1, '');

      SELECT @sqlColumnsListToCreate = @sqlColumnsListToCreate + '[' + COALESCE(cm.SourceColumn, c.column_name) + '] varchar(100),' 
        FROM INFORMATION_SCHEMA.COLUMNS c
		     LEFT JOIN cfg.ColumnMapping cm
			        ON c.table_name = cm.TargetTable
				   AND c.column_name = cm.TargetColumn
       WHERE c.table_name = @stgTableName
	     AND c.column_name != 'Upload_ID'
		 AND cm.Ignore IS NULL
	   ORDER BY c.ORDINAL_POSITION;
      
	  -- remove the last ','
	  SET @sqlColumnsListToCreate = STUFF(@sqlColumnsListToCreate, LEN(@sqlColumnsListToCreate), 1, '');

      SELECT @sqlCheckRules = @sqlCheckRules + 'SELECT ''' + CAST(@uploadID as varchar) + ''' AS Upload_ID, ''' + @fileName + ''' AS File_Name, ''' +
	                          c.column_name + ''' AS Column_Name, ' +
							  'CAST(' + COALESCE(cm.TransformationFormula, c.column_name) + ' as varchar) AS Value, ' +
							  'CAST(TRY_CAST(COALESCE(' + COALESCE(cm.TransformationFormula, c.column_name) +
	                          CASE
							     WHEN COALESCE(cm.TargetColumnDataType, c.data_type) IN ('date', 'datetime', 'datetime2')
								    THEN ', ''1900/01/01'') AS DATE) AS VARCHAR)'
							     WHEN COALESCE(cm.TargetColumnDataType, c.data_type) IN ('bigint', 'float', 'int', 'numeric', 'smallint', 'tinyint')
								    THEN ', ''0'') AS NUMERIC) AS VARCHAR)'
							  END + ' AS isValidDataType, ' +
							  CASE
							     WHEN COALESCE(cm.TargetColumnDataType, c.data_type) IN ('date', 'datetime', 'datetime2')
								    THEN '''Date'''
							     WHEN COALESCE(cm.TargetColumnDataType, c.data_type) IN ('bigint', 'float', 'int', 'numeric', 'smallint', 'tinyint')
								    THEN '''Numeric'''
							  END + ' AS DataType FROM ' + @tmpTableName + ' UNION '
        FROM INFORMATION_SCHEMA.COLUMNS c
		     LEFT JOIN (SELECT DISTINCT TargetTable, TargetColumn, TargetColumnDataType, TransformationFormula, Ignore FROM cfg.ColumnMapping) cm
			        ON c.table_name = cm.TargetTable
				   AND c.column_name = cm.TargetColumn
       WHERE c.table_name = @stgTableName
         AND c.column_name != 'Upload_ID'
		 AND COALESCE(cm.TargetColumnDataType, c.data_type) IN ('date', 'datetime', 'datetime2', 'bigint', 'float', 'int', 'numeric', 'smallint', 'tinyint')
		 AND cm.Ignore IS NULL
	   ORDER BY c.ORDINAL_POSITION;

	  SELECT @sqlCheckRules = LEFT(@sqlCheckRules, LEN(@sqlCheckRules) - 6);

	  SET @sqlInsertSTG = 'INSERT INTO dbo.' + @stgTableName + '(';

	  SELECT @sqlInsertSTG = @sqlInsertSTG + column_name + ',' 
        FROM INFORMATION_SCHEMA.COLUMNS c
		     LEFT JOIN (SELECT DISTINCT TargetTable, TargetColumn, TargetColumnDataType, TransformationFormula, Ignore FROM cfg.ColumnMapping) cm
			        ON c.table_name = cm.TargetTable
				   AND c.column_name = cm.TargetColumn
       WHERE c.table_name = @stgTableName
		 AND cm.Ignore IS NULL
	   ORDER BY c.ORDINAL_POSITION;

	  -- remove the last ','
	  SET @sqlInsertSTG = STUFF(@sqlInsertSTG, LEN(@sqlInsertSTG), 1, '') + ') SELECT ';

      SELECT @sqlInsertSTG = @sqlInsertSTG + COALESCE(cm.TransformationFormula, c.column_name) + ','
        FROM INFORMATION_SCHEMA.COLUMNS c
		     LEFT JOIN (SELECT DISTINCT TargetTable, TargetColumn, TransformationFormula, Ignore FROM cfg.ColumnMapping) cm
			        ON c.table_name = cm.TargetTable
				   AND c.column_name = cm.TargetColumn
       WHERE c.table_name = @stgTableName
         AND c.column_name != 'Upload_ID'
		 AND cm.Ignore IS NULL
	   ORDER BY c.ORDINAL_POSITION;

	  SET @sqlInsertSTG = @sqlInsertSTG + CAST(@uploadID as varchar) + ' FROM ' + @tmpTableName;
	  

	  SET @sqlIngest = 'IF OBJECT_ID(''.dbo.' + @tmpTableName + ''') IS NOT NULL DROP TABLE ' + @tmpTableName + 
	                 '; CREATE TABLE ' + @tmpTableName + '(' + @sqlColumnsListToCreate + ');
	                     BULK INSERT ' + @tmpTableName +
                             ' FROM ''' + @fullFileName + '''
                           WITH
                           (   MAXERRORS = 0,
                               FIRSTROW = 2,
                               FIELDTERMINATOR = '','',  --CSV field delimiter
                               ROWTERMINATOR = ''\n'',   --Use to shift the control to next row
                               TABLOCK
                           );';

      SET @sqlInsertErrorLog = 'INSERT INTO log.Error_Log(Upload_ID, File_Name, Column_Name, Error_Message, Create_Date)
					            SELECT Upload_ID, File_Name, Column_Name, CONCAT(Value, '': is not valid '', DataType), CURRENT_TIMESTAMP
					              FROM (' + @sqlCheckRules + ') t
					             WHERE isValidDataType IS NULL;'
	  
      BEGIN TRY
	     
	     EXEC(@sqlIngest);

	     BEGIN TRY
	        EXEC(@sqlInsertSTG);

		    INSERT INTO [log].[File_Upload](Id, File_Name, Status, Row_Count, Upload_Date)
		           VALUES(@uploadID, @fileName, 'Complete', @@ROWCOUNT, CURRENT_TIMESTAMP);
            

			SET @sqlMoveFiles = 'master..xp_cmdshell ''ECHO move /Y C:\Data\Datamine\' +
			                    @fileName + ' C:\Data\Datamine\Archive\' + REPLACE(@fileName, '.csv', '') + '_%date:~10,4%%date:~4,2%%date:~7,2%.csv >> E:\batch\mv_files.bat''';
			SET @sqlSuccessMsg = 'ECHO SUCCEEDED: ' + @fileName + ' >> E:\CheckFiles\RunStatus.txt';
	     END TRY
	     
	     BEGIN CATCH
	        EXEC(@sqlInsertErrorLog);

		    INSERT INTO [log].[File_Upload](Id, File_Name, Status, Row_Count, Upload_Date)
		           VALUES(@uploadID, @fileName, 'Failed', NULL, CURRENT_TIMESTAMP);

			SET @sqlSuccessMsg = 'ECHO FAILED: ' + @fileName + ' >> E:\CheckFiles\RunStatus.txt';
	     END CATCH

	  END TRY

	  BEGIN CATCH
	     INSERT INTO log.Error_Log(Upload_ID, File_Name, Column_Name, Error_Message, Create_Date)
			       VALUES(@uploadID, @fileName, NULL, 'Failed to ingest CSV file: ' + @fileName + ' please check if number of columns match', CURRENT_TIMESTAMP);
		 INSERT INTO [log].[File_Upload](Id, File_Name, Status, Row_Count, Upload_Date)
		        VALUES(@uploadID, @fileName, 'Failed', NULL, CURRENT_TIMESTAMP);

		SET @sqlSuccessMsg = 'ECHO FAILED: ' + @fileName + ' >> E:\CheckFiles\RunStatus.txt';
	  END CATCH

END

DELETE FROM #TMP_FILENAMES WHERE File_Name = @fileName;

EXEC(@sqlMoveFiles);
exec master..xp_cmdshell @sqlSuccessMsg, NO_OUTPUT;

SET @sqlMoveFiles = '';

END

SET IDENTITY_INSERT [log].[File_Upload] OFF;

exec sp_configure 'xp_cmdshell', 0;
reconfigure;

END;