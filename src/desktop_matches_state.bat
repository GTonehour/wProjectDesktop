@echo off
setlocal enabledelayedexpansion

REM Get current desktop number
call "%~dp0virtualdesktop_exe.bat"

for /f "tokens=2 delims='" %%a in ('"%exe_path%" /GetCurrentDesktop 2^>nul') do set "currentDesktopName=%%a"

REM Read current project from file
if not exist "..\State\currentProject.txt" (
    exit /b 2
)
set /p currentProject=<"..\State\currentProject.txt"

REM Compare and return appropriate exit code
if "%currentDesktopName%"=="%currentProject%" (
    exit /b 0
) else (
    exit /b 1
)
