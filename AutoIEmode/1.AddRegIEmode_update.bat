@echo off
echo  ===========================================
echo      A U T O   L A U N C H   I E   M O D E  
echo           O N   M S   E D G E
echo  ===========================================
echo.

REM Get the directory of the current batch file
set "script_dir=%~dp0"

REM Set the path to the XML file located in the same directory as the script
set "xml_file=%script_dir%IEList.xml"

REM Add registry entries
echo Adding IE Integration Level:
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v InternetExplorerIntegrationLevel /t REG_DWORD /d 1 /f
if %ERRORLEVEL% neq 0 (
    echo Failed to add InternetExplorerIntegrationLevel registry entry. Exiting.
    pause
    exit /b 1
)

echo ----------------------
echo Adding IE Integration Site List:
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v InternetExplorerIntegrationSiteList /t REG_SZ /d "%xml_file%" /f
if %ERRORLEVEL% neq 0 (
    echo Failed to add InternetExplorerIntegrationSiteList registry entry. Exiting.
    pause
    exit /b 1
)

echo ----------------------
echo Both registry entries added successfully.
echo Checking if Microsoft Edge is running...

REM Check if msedge.exe is running
tasklist /FI "IMAGENAME eq msedge.exe" 2>NUL | find /I "msedge.exe" >NUL
if %ERRORLEVEL%==0 (
    echo Microsoft Edge is running. Force shutting down Microsoft Edge......
    taskkill /F /IM msedge.exe
) else (
    echo Microsoft Edge is not running. Ending script...
)

echo.
echo.
echo --------------------------------
echo ^|   /\_/\   !End of the script!				
echo ^|  ( -.- )   huynm3@msb.com.vn
echo ^|   o(")_(")					
echo --------------------------------

pause
