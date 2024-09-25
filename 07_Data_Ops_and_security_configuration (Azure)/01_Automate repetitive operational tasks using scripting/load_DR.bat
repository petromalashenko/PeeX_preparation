@echo off

set count=0
set rt_fld="%CD%\"
cd %~dp0
call config.bat

rem build network folder
if exist Z: (
	net use Z: /delete /y
	)
net use Z: "\\%hostname%\E$" %pwd% /user:%user%

set log=%rt_fld%LOG\log_upload_DeferalsRequest_%date:~10,4%%date:~4,2%%date:~7,2%.txt
set tgt_fld=Z:\HTBI_DW\External_Data\Inbound\CovidDeferrals\%date:~10,4%\%date:~4,2%\CovidFiles_%date:~10,4%%date:~4,2%%date:~7,2%\
set tgt_fld_pr=Z:\HTBI_DW\External_Data\Inbound\CovidDeferrals\
set etl_log=Z:\HTBI_DW\LOG\PROD\COVID_DEFERRALS\
set fl_name=%rt_fld%*Requests*.xls*
set tgt_fl_name=%rt_fld%DeferalsRequest.csv
set mbody=""

echo. >> %log%
echo. >> %log%
echo *** START *** >> %log%
echo. >> %log%
echo. >> %log%


:fl_loop
if %count% gtr 48 (
echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% file "DeferalsRequest" not provided... end of process >> %log%
set mbody="'DeferalsRequest' not provided"
goto :end
)
if exist %fl_name% (
    echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% file exists >> %log%
	if not exist %tgt_fld% (
		mkdir %tgt_fld%
		echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% folder %tgt_fld% created >> %log%
	)
	:run_excel
	if not exist %fl_name% (
		set mbody="FAILURE: Save the source file manualy and re-run the script"
		goto :end 
	)
	start "C:\Program Files (x86)\Microsoft Office\root\Office16\excel.exe" "DR_cln.xlsm" && (
	timeout 100
	if exist %tgt_fl_name% (
		echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% file "DeferalsRequest.csv" cleaned for uploading >> %log%
	) else (
		taskkill /F /IM excel.exe
		goto :run_excel
	)
	) || (
	echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% FAILURE: Excel macro couldn't clean "DeferalsRequest.csv" >> %log%
	set mbody="FAILURE: Excel macro couldn't clean 'DeferalsRequest.csv'"
    goto :end
	)
	for /F "tokens=* delims= " %%G in ('copy /y %tgt_fl_name% %tgt_fld%') do echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% file "DeferalsRequest.csv" %%G to %tgt_fld% >> %log%
	for /F "tokens=* delims= " %%G in ('move /y %tgt_fl_name% %tgt_fld_pr%') do (
			echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% file "DeferalsRequest.csv" %%G to %tgt_fld_pr% >> %log%
		SchTasks /Run /S HTCETLPRD004 /TN JS_000_HTBI_FORMSTACK_DEFERRAL_REQ_BW && (
				echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% Task JS_000_HTBI_FORMSTACK_DEFERRAL_REQ_BW is running check the log on ETL server >> %log%
				) || (
				set mbody="FAILURE: Task JS_000_HTBI_FORMSTACK_DEFERRAL_REQ_BW did't start"
				echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% FAILURE: Task JS_000_HTBI_FORMSTACK_DEFERRAL_REQ_BW did't start >> %log%
				goto :end
				)
	)
	del %fl_name% /f /q	
	
) else (
    echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% file doesn't exist: loop %count% >> %log%
	set /a count+=1
	timeout 300
	goto :fl_loop
)

echo.
echo WAIT 60 seconds to let the ETL complete
echo.

timeout 60

set count=0
set flnm=""
	
	:lg_loop
	for /f %%a in ('forfiles /P %etl_log% /M Build_RPT_FormStack_Deferra_Request*.log /D +%date:~4,2%/%date:~7,2%/%date:~10,4%') do set flnm=%%a
	if not %flnm% == "" (
		echo. >> %log%
		echo from ETL log %flnm% >> %log%
		echo. >> %log%
		:read_log
		for /f "delims=" %%b in ('findstr /c:"Delivery 'RPT_FormStack'" %etl_log%\%flnm%') do (
		echo %%b >> %log%
		set mbody=%%b
		goto :send_email
		)
		for /f "delims=" %%b in ('findstr /c:"Build 'RPT_FormStack_Deferra_Request' Failed" %etl_log%\%flnm%') do (
		echo "ETL job failed: "%%b >> %log%
		set mbody="FAILURE: ETL job failed: "%%b
		goto :end
		)
		timeout 10
		goto :read_log
	) else (
	if %count% gtr 20 (
		echo %date:~10,4%-%date:~4,2%-%date:~7,2%_%time: =0% couldn't find ETL log file... end of process >> %log%
		set mbody="couldn't find ETL log file..."
		goto :end
	)
	set /a count+=1
	timeout 10
	goto :lg_loop
	)

:send_email
set mbody="SUCCEEDED:    "%mbody%

rem *** SEND EMAIL SUCEEDED

rem	1)user 
rem 2)password 
rem 3)email_from 
rem 4)subject	
rem 5)body

rem !!! if needed to correct email recepients list do it in 'send_email_DR_SUCCEEDED.ps1'

set mbody="%mbody:'=''%

powershell ./send_email_DR_SUCCEEDED.ps1 '%user%' '%pwd%' 'petro.malashenko@hometrust.ca' 'SUCCEEDED: DeferalsRequest uploading status' '%mbody%'
rem *** END SEND SUCEEDED

goto :end_end

:end

rem *** SEND EMAIL FAILURE

rem	1)user 
rem 2)password 
rem 3)email_from 
rem 4)subject	
rem 5)body

rem !!! if needed to correct email recepients list do it in 'send_email_DR_FAILURE.ps1'

set mbody="%mbody:'=''%

powershell ./send_email_DR_FAILURE.ps1 '%user%' '%pwd%' 'petro.malashenko@hometrust.ca' 'FAILURE: DeferalsRequest uploading status' '%mbody%'

rem *** END SEND FAILURE

:end_end
echo. >> %log%
echo. >> %log%
echo *** END *** >> %log%
echo. >> %log%
echo. >> %log%
