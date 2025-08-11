@echo off
setlocal enabledelayedexpansion

REM Set the executable path
if defined wPD_VirtualDesktop_exe (
    set "exe_path=%wPD_VirtualDesktop_exe%"
) else (
    set "exe_path=%LocalAppData%\wProjectDesktop\bin\VirtualDesktop.exe"
)

endlocal & set "exe_path=%exe_path%"
