call :Gettime Timestamp
call :Gettime START_SCRIPT

::Config
::mail variables
set "mailFrom=mailFrom"
set mailAddress=mailAddress@gmail.com
set mailPass=mailPass
set mailSMTP=mailSMTP
set mailRecipients=mailRecipients@gmail.com
set "mailSubject==?UTF-8?Q?Wysy=C5=82ka zanonimizowanej bazy danych?="
set mailLog=mailsend_report_%Timestamp%.txt

::path variables
set PATH=%PATH%;C:\Program Files (x86)\WinSCP\;C:\Program Files\7-Zip\
set localPath=C:\db\
set ftpPath=/home/user/bazodanowy/Backups/
set destinationPath=/newDB/

::database variables
set dbData=DESKTOP-QPGNSQ5\SQL
set nameAnonymizatedDb=db_prod_ano
set nameBackupDb=db_prod_full
set nameDb=db_prod
set logDb=db_prod_log


::Get db from ftp
call :Gettime START_GET_DB
echo get -latest "%ftpPath%*.7z" "%localPath%" > wscp_get.txt
type wscp_script_get_start.txt wscp_get.txt wscp_script_end.txt > wscp_script_get_exec.txt

winscp.com /ini=nul /script=wscp_script_get_exec.txt > wscp_report_get_%Timestamp%.txt
call :Gettime STOP_GET_DB

::Report timeing
echo START_GET_DB=%START_GET_DB% > execution_report.txt
echo STOP_GET_DB=%STOP_GET_DB% >> execution_report.txt

::Get latest 7z
@echo off
    setlocal enableextensions disabledelayedexpansion

    set "mask=*.7z"

    for %%r in ("%localPath%\.") do for /f "tokens=2,*" %%a in ('
        robocopy "%%~fr" "%%~fr" "%mask%" /njh /njs /nc /ns /ts /s /ndl /nocopy /is /r:0 /w:0 /l
        ^| sort /r 
        ^| cmd /v /e /c"(set /p .=&echo(!.!)"
    ') do set "lastFile=%%b"
	
    echo Last file: "%lastFile%" >> execution_report.txt

::Extract downloaded 7z
call :Gettime START_EXTRACT
7z e "%lastFile%"
call :Gettime STOP_EXTRACT

::Report timeing
echo START_EXTRACT=%START_EXTRACT% >> execution_report.txt
echo STOP_EXTRACT=%STOP_EXTRACT% >> execution_report.txt

::Set variables 
set lastFileMDF=%lastFile:~0,-3%__.mdf
set lastFileLDF=%lastFile:~0,-3%__.ldf
set zipNameWithRoot=%lastFile:~0,-3%_ano_%Timestamp%.7z
set zipName=%zipNameWithRoot:~22,52%

echo lastFileMDF=%lastFileMDF% >> execution_report.txt
echo lastFileLDF=%lastFileLDF% >> execution_report.txt
echo zipNameWithRoot=%zipNameWithRoot% >> execution_report.txt
echo zipName=%zipName% >> execution_report.txt

::Restore datadase
call :Gettime START_RESTORE_DB
sqlcmd -S %dbData% -E -Q "RESTORE DATABASE [%nameAnonymizatedDb%] FROM DISK = '%localPath%%nameBackupDb%.bak' WITH MOVE '%nameDb%' TO '%lastFileMDF%', MOVE '%logDb%' TO '%lastFileLDF%'"	
call :Gettime STOP_RESTORE_DB

::Report timeing
echo START_RESTORE_DB=%START_RESTORE_DB% >> execution_report.txt
echo STOP_RESTORE_DB=%STOP_RESTORE_DB% >> execution_report.txt

::anonymization
call :Gettime START_ANONYMIZATION_DB
sqlcmd -S %dbData% -E -i anonymization.sql
sqlcmd -S %dbData% -E -i shrinkdb.sql
call :Gettime STOP_ANONYMIZATION_DB

::Report timeing
echo START_ANONYMIZATION_DB=%START_ANONYMIZATION_DB% >> execution_report.txt
echo STOP_ANONYMIZATION_DB=%STOP_ANONYMIZATION_DB% >> execution_report.txt

::Backup database
call :Gettime START_BACKUP_DB
sqlcmd -S %dbData% -E -Q "BACKUP DATABASE [%nameAnonymizatedDb%] TO  DISK = N'%localPath%%nameAnonymizatedDb%.bak' WITH NOFORMAT, NOINIT,  NAME = N'%nameAnonymizatedDb%-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10"
call :Gettime STOP_BACKUP_DB

::Report timeing
echo START_BACKUP_DB=%START_BACKUP_DB% >> execution_report.txt
echo STOP_BACKUP_DB=%STOP_BACKUP_DB% >> execution_report.txt

::Archive database
call :Gettime START_ARCHIVE_DB
7z a %zipName% %nameAnonymizatedDb%.bak
call :Gettime STOP_ARCHIVE_DB

::Report timeing
echo START_ARCHIVE_DB=%START_ARCHIVE_DB% >> execution_report.txt
echo STOP_ARCHIVE_DB=%STOP_ARCHIVE_DB% >> execution_report.txt

::Send db to destination
call :Gettime START_SEND_DB
echo put -delete "%zipName%" "%destinationPath%" > wscp_put.txt
type wscp_script_put_start.txt wscp_put.txt wscp_script_end.txt > wscp_script_put_exec.txt

winscp.com /ini=nul /script=wscp_script_put_exec.txt > wscp_report_put_%Timestamp%.txt
call :Gettime STOP_SEND_DB

::Report timeing
echo START_SEND_DB=%START_SEND_DB% >> execution_report.txt
echo STOP_SEND_DB=%STOP_SEND_DB% >> execution_report.txt

::Delete database
call :Gettime START_DROP_DB
sqlcmd -S %dbData% -E -Q "DROP DATABASE [%nameAnonymizatedDb%]"
call :Gettime STOP_DROP_DB

::Report timeing
echo START_DROP_DB=%START_DROP_DB% >> execution_report.txt
echo STOP_DROP_DB=%STOP_DROP_DB% >> execution_report.txt

::Delete unnecessary files
call :Gettime START_CLEANING
DEL wscp_get.txt wscp_script_get_exec.txt wscp_report_get_%Timestamp%.txt
DEL wscp_put.txt wscp_script_put_exec.txt wscp_report_put_%Timestamp%.txt
DEL %nameAnonymizatedDb%.bak %nameBackupDb%.bak %lastFile%
call :Gettime STOP_CLEANING

::Report timeing
echo START_CLEANING=%START_CLEANING% >> execution_report.txt
echo STOP_CLEANING=%STOP_CLEANING% >> execution_report.txt

call :Gettime END_SCRIPT

::Report timeing
echo START_SCRIPT=%START_SCRIPT% >> execution_report.txt
echo END_SCRIPT=%END_SCRIPT% >> execution_report.txt

::Create mail body
echo Hej, > mailbody.txt
echo wysłałem bazę >> mailbody.txt
type execution_report.txt >> mailbody.txt
echo Wysłany plik: %destinationPath%%zipName% >> mailbody.txt
echo Pozdrawiam >> mailbody.txt

::Send mail with report
mailsend1.19.exe -v -name "%mailFrom%" -f %mailAddress% -user %mailAddress% -pass "%mailPass%" -auth-login -ssl -port 465 -smtp %mailSMTP% -t %mailRecipients% -sub "%mailSubject%" -cs "utf-8" -enc-type "base64" -mime-type "text/plain" -msg-body "mailbody.txt" -log %mailLog%

::Delete unnecessary files
DEL mailbody.txt %mailLog% execution_report.txt


::Get time function
:Gettime
for /f "delims=" %%i in ('echo %TIME: =0%') do set CURTIME=%%i
SET ret=%date:~6,4%%date:~3,2%%date:~0,2%_%CURTIME:~0,2%%CURTIME:~3,2%%CURTIME:~6,2%
set "%~1=%ret%"

EXIT /B 0