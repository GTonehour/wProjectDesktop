@echo off
setlocal enabledelayedexpansion

REM Get current desktop number
call "%~dp0virtualdesktop_exe.bat"

REM Run command and capture output
"%exe_path%" /GetCurrentDesktop > "%TEMP%\wdp_out.txt" 2>&1

set "currentDesktopName="
for /f "tokens=2 delims='" %%a in ('type "%TEMP%\wdp_out.txt" ^| findstr /C:"Current desktop:"') do set "currentDesktopName=%%a"
if exist "%TEMP%\wdp_out.txt" del "%TEMP%\wdp_out.txt"

if "%currentDesktopName%"=="" (
    exit /b 3
)

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

