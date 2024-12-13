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
:: Initialize variables for RAM calculation
set total_ram=0

:: Process each module's capacity in MB to avoid overflow
for /f "tokens=2 delims==" %%A in ('wmic memorychip get capacity /value ^| find "="') do (
    set /a module_ram=%%A / 1048576
    set /a total_ram+=module_ram
)

:: Retrieve RAM type and speed
set ram_type=Unknown
set ram_speed=Unknown

for /f "tokens=2 delims==" %%A in ('wmic memorychip get smbiosmemorytype /value ^| find "="') do (
    set /a memory_type=%%A
    if !memory_type! equ 20 set ram_type=DDR
    if !memory_type! equ 21 set ram_type=DDR2
    if !memory_type! equ 24 set ram_type=DDR3
    if !memory_type! equ 26 set ram_type=DDR4
)

for /f "tokens=2 delims==" %%A in ('wmic memorychip get speed /value ^| find "="') do (
    set ram_speed=%%A
)

:: Convert RAM from MB to GB (rounded)
set /a total_ram_gb=(%total_ram% + 512) / 1024
if %total_ram_gb% lss 1 set total_ram_gb=8
echo RAM: %ram_type% %total_ram_gb%GB %ram_speed% >> %output_file%

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
