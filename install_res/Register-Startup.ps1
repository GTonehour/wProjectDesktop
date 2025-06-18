function Register-Startup {
	param (
		$FullPathToStartupFile
	)
	# Register-ScheduledTask and schtasks with BootTrigger would start earlier but require admin rights. We try not to require admin rights. We could also `copy "startup.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"`.
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" /d "PowerShell.exe -ExecutionPolicy Bypass -File `"$FullPathToStartupFile`""
# reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" # To read.
}

