@echo off

:: Call PowerShell to get the type of the disk
for /f "tokens=*" %%A in ('powershell -NoProfile -Command "Get-Disk | Where-Object { $_.PartitionStyle -ne 'RAW' } | Select-Object -First 1 -ExpandProperty BusType"') do (
    set "DiskType=%%A"
)

:: Display the disk type
echo Detected Disk Type: %DiskType%

:: Conditional handling in CMD based on disk type
if /i "%DiskType%"=="NVMe" (
    echo The disk type is NVMe. Proceeding with NVMe-specific tasks...
) else (
    echo The disk is not NVMe. Skipping NVMe tasks...
)

pause
