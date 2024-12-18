@echo off
setlocal enabledelayedexpansion

:: Get the serial number for naming the output file
for /f "tokens=2 delims==" %%A in ('wmic bios get serialnumber /value ^| find "="') do set serial_number=%%A
set output_file=%serial_number%.txt

:: Create or overwrite the output file and write SN in the format SN: XXXX
echo SN: %serial_number% > %output_file%

:: CPU name and clock speed
for /f "tokens=2 delims==" %%A in ('wmic cpu get name /value ^| find "="') do set cpu_name=%%A
echo CPU: %cpu_name% >> %output_file%

::----------------------------------------GET RAM DETAILS----------------------------------------
::GET RAM DETAILS - START FROM HERE
set count_ram_stick=0
set total_ram=0

for /f "tokens=1,2 delims==" %%A in ('wmic memorychip get capacity^, smbiosmemorytype^, speed /format:list ^| find "="') do (
    if "%%A"=="Capacity" (
        set "module_bytes=%%B"
        set /a module_ram=!module_bytes:~0,-7! / 1024
        if not defined module_ram set module_ram=0

        set /a count_ram_stick+=1
        set /a total_ram+=!module_ram!
        
        set "ram_output=RAM !count_ram_stick!: !module_ram!GB"
    )
    if "%%A"=="SMBIOSMemoryType" (
        set /a memory_type=%%B
        if !memory_type! equ 20 set ram_type=DDR
        if !memory_type! equ 21 set ram_type=DDR2
        if !memory_type! equ 24 set ram_type=DDR3
        if !memory_type! equ 26 set ram_type=DDR4
        if !memory_type! gtr 26 set ram_type=DDR5
        set ram_output=!ram_output! !ram_type!
    )
    if "%%A"=="Speed" (
        set ram_speed=%%B
        set ram_output=!ram_output! !ram_speed!
		
	    <nul set /p =" !ram_output!" >> %output_file%
        REM echo !ram_output! >> %output_file%
    )
)

:: Total RAM
set /a total_ram_gb=%total_ram%
if %count_ram_stick% geq 2 (
    echo Tổng RAM: %total_ram_gb%GB >> %output_file%
)

REM set /a total_ram_gb=%total_ram%
REM echo Total RAM: %total_ram_gb%GB >> %output_file%
::GET RAM DETAILS - END HERE

::----------------------------------------GET HARDDISK DETAILS----------------------------------------
for /f "skip=1 tokens=1,2,3* delims=," %%A in ('wmic diskdrive get model^,size^,mediatype /format:csv 2^>nul') do (
    set "model=%%C"
    set "raw_size=%%D"
    set "type=%%B"
    
    for /f "delims= " %%E in ("!raw_size!") do set raw_size=%%E
    
    if not "!raw_size!"=="" (
        set /a size_gb=!raw_size:~0,-9! 2>nul
        if "!size_gb!"=="" set size_gb=0
    ) else (
        set size_gb=0
    )
    
    if /i "!type!"=="Fixed hard disk media" if !size_gb! gtr 0 (
        set "disk_info=!model! !size_gb!GB"
    )
)

if "!disk_info!"=="" set disk_info=No disk detected
echo Ổ cứng: %disk_info% >> %output_file%

:: Notify completion
echo System information has been saved to %output_file%.
pause
