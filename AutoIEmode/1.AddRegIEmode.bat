@echo off
REM Get the directory of the current batch file
set "script_dir=%~dp0"

REM Set the path to the XML file located in the same directory as the script
set "xml_file=%script_dir%IEList.xml"

REM Add registry entries
echo Adding IE Level:
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v InternetExplorerIntegrationLevel /t REG_DWORD /d 1 /f
echo ----------------------
echo Adding IE Site List:
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v InternetExplorerIntegrationSiteList /t REG_SZ /d "%xml_file%" /f
echo ----------------------

pause
