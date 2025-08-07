@echo off
setlocal enabledelayedexpansion

REM Get current desktop number
call "%~dp0get_current_desktop.bat"

REM Extract desktop number from parentheses
set "desktop_line=%desktop_output%"
for /f "tokens=2 delims=()" %%a in ("%desktop_line%") do (
    set "number_part=%%a"
    REM Extract just the number from "desktop number X"
    for /f "tokens=3" %%b in ("!number_part!") do set "currentDesktopNumber=%%b"
)

REM Execute the remove command
echo Removing desktop number %currentDesktopNumber%...
"%exe_path%" /Remove:%currentDesktopNumber%
