@echo off
setlocal enabledelayedexpansion

:: Input disk to match
set /p inputDisk=Enter the disk name (e.g., disk01): 

:: Path to the text file (in the same folder as this script)
set file=%~dp0disks.txt

:: Check if the file exists
if not exist "%file%" (
    echo File "disks.txt" not found in the script folder.
    goto :end
)

:: Loop through each line in the file
for /f "tokens=1,2 delims=	" %%A in ('type "%file%"') do (
    if "%%A"=="%inputDisk%" (
        echo %%B
        goto :end
    )
)

:: If no match is found
echo Disk "%inputDisk%" not found in the file.

:end
pause
