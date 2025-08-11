@echo off
setlocal enabledelayedexpansion

call "%~dp0virtualdesktop_exe.bat"

"%exe_path%" /GetCurrentDesktop /Remove
