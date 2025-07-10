function Register-Startup {
	param (
		$FullPathToStartupFile
	)
	
	Write-Host "Choose startup method:" -ForegroundColor Cyan
	Write-Host "1. Standard startup"
	Write-Host "2. Faster startup, requires admin"
	
	$choice = Read-Host "Enter your choice (1 or 2, default is 1)"
	
	if ($choice -eq "2") {
		Write-Host "Using faster startup method (requires admin)..."
		
$template = Get-Content "$PSScriptRoot\StartupTask.xml" -Raw -Encoding UTF8
$result = $ExecutionContext.InvokeCommand.ExpandString($template)

# Create UTF-8 without BOM
$tempXmlPath = "$PSScriptRoot\StartupTask_generated.xml"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($tempXmlPath, $result, $utf8NoBom)
		
$command1 = "schtasks /create /xml `"$tempXmlPath`" /tn `"\wProjectDesktop\wProjectDesktop_Startup`" /RU `"$env:USERNAME`""
$command2 = "Remove-Item `"$tempXmlPath`" -Force"
$combinedCommand = "$command1; $command2"
# $combinedCommand = "$command1"

# Remove-Item wouldn't need admin rights ; BUT it needs to wait for command1 to end.
Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-Command", $combinedCommand
		Write-Host "Using standard startup method..."
		Write-Host "Admin prompt opened. Please complete the task creation." -ForegroundColor Yellow
	} else {
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" /d "PowerShell.exe -ExecutionPolicy Bypass -File `"$FullPathToStartupFile`""
# reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" # To read.
# reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" /f
		Write-Host "Startup registered successfully" -ForegroundColor Green
	}
}
