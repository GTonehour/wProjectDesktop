function Register-Startup {
	param (
		$StartupFile
	)
	# Register-ScheduledTask, schtasks with BootTrigger, all require admin rights. We try not to require admin rights. We could also `copy "startup.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"`.
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" /d "PowerShell.exe -ExecutionPolicy Bypass -File `"$StartupFile`""
}

