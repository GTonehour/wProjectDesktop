@echo off
setlocal enabledelayedexpansion

REM Common desktop utility functions
REM This file should be called from other batch files

REM Set the executable path
if defined wPD_VirtualDesktop_exe (
    set "exe_path=%wPD_VirtualDesktop_exe%"
) else (
    set "exe_path=%LocalAppData%\wProjectDesktop\bin\VirtualDesktop.exe"
)

REM Get current desktop output
for /f "tokens=*" %%i in ('"%exe_path%" /GetCurrentDesktop 2^>nul') do set "desktop_output=%%i"

REM Make variables available to calling script
endlocal & set "exe_path=%exe_path%" & set "desktop_output=%desktop_output%"
