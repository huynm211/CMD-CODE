@echo off
for /f "tokens=2 delims==, " %%A in ('wmic bios get releasedate /format:list') do (
    set date=%%A
)
set formattedDate=%date:~0,4%-%date:~4,2%-%date:~6,2%
echo BIOS Release Date: %formattedDate%
pause