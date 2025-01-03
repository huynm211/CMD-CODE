@echo off
setlocal enabledelayedexpansion

:: Get the serial number for naming the output file
for /f "tokens=2 delims==" %%A in ('wmic bios get serialnumber /value ^| find "="') do set serial_number=%%A
set output_file=%serial_number%.txt

:: Create or overwrite the output file and write SN in the format SN: XXXX
echo SN: %serial_number% > %output_file%

:: CPU name and clock speed
for /f "tokens=2 delims==" %%A in ('wmic cpu get name /value ^| find "="') do set cpu_name=%%A
for /f "tokens=2 delims==" %%A in ('wmic cpu get maxclockspeed /value ^| find "="') do set /a cpu_speed=%%A / 1000
set cpu_speed=!cpu_speed:.=!
if "!cpu_speed!"=="" set cpu_speed=1.60
echo CPU: %cpu_name%>> %output_file%

::--------------------------------------------------------------------------------------
set total_ram=0
set ram_type=Unknown
set ram_speed=Unknown

:: Process each memory module
for /f "tokens=1,2 delims==" %%A in ('wmic memorychip get capacity^, smbiosmemorytype^, speed /format:list ^| find "="') do (
	if "%%A"=="Capacity" (
        set "module_bytes=%%B"
        REM Convert bytes to MB by removing the last 7 digits (divide by 1048576)
		set "module_ram=!module_bytes:~0,-7!"
		
		if not defined module_ram set module_ram=0
		set /a total_ram+=!module_ram!
		
		REM set /a module_ram_gb=(!module_ram! + 512) / 1024
		<nul set /p=RAM: !module_ram!GB >> %output_file%
    )
	
	if "%%A"=="SMBIOSMemoryType" (
        set /a memory_type=%%B
        if !memory_type! equ 20 set ram_type=DDR
        if !memory_type! equ 21 set ram_type=DDR2
        if !memory_type! equ 24 set ram_type=DDR3
        if !memory_type! equ 26 set ram_type=DDR4
		
		<nul set /p=!ram_type! >> %output_file%
    )
	
    
    
    if "%%A"=="Speed" (
        set ram_speed=%%B
		
		<nul set /p=!ram_speed! >> %output_file%
    )
	REm echo RAM: %ram_type% %module_ram%GB %ram_speed% >> %output_file%
)

:: Convert total RAM from MB to GB (rounded)
set /a total_ram_gb=(total_ram + 512) / 1024
if %total_ram_gb% lss 1 set total_ram_gb=Unknown

:: Output result
echo Total RAM: %ram_type% %total_ram_gb%GB %ram_speed% >> %output_file%
::--------------------------------------------------------------------------------------
:: Disk detection
set disk_info=

:: Retrieve disk information dynamically
for /f "skip=1 tokens=1,2,3* delims=," %%A in ('wmic diskdrive get model^,size^,mediatype /format:csv 2^>nul') do (
    set "model=%%C"
    set "raw_size=%%D"
    set "type=%%B"
    
    :: Remove spaces and verify the raw_size is valid
    for /f "delims= " %%E in ("!raw_size!") do set raw_size=%%E
    
    if not "!raw_size!"=="" (
        set /a size_gb=!raw_size:~0,-9! 2>nul
        if "!size_gb!"=="" set size_gb=0
    ) else (
        set size_gb=0
    )
    
    :: Only include "Fixed hard disk media" with valid size
    if /i "!type!"=="Fixed hard disk media" if !size_gb! gtr 0 (
        if "!disk_info!"=="" (
            set "disk_info=!model! !size_gb!GB"
        ) else (
            set "disk_info=!disk_info!, !model! "
        )
    )
)

:: Handle the case where no disk is detected
if "!disk_info!"=="" set disk_info=No disk detected

::-----------------------------------------------------------------------------------------
:: Write to the output file
echo Ổ cứng: %disk_info% >> %output_file%

:: Notify completion
echo System information has been saved to %output_file%.
pause
