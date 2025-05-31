param(
    [string]$TaskName = "wProjectSetup"
)

$ErrorActionPreference = "Stop"

# Define installation directory
$InstallDir = "$env:LOCALAPPDATA\wProjectDesktop"
$MainScriptPath = Join-Path $InstallDir "Startup.ps1"

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Verify Startup.ps1 exists in source
$SourceStartupPath = Join-Path $ScriptDir "Startup.ps1"
if (-not (Test-Path $SourceStartupPath)) {
    throw "Startup.ps1 not found in $ScriptDir"
}

# Create installation directory if it doesn't exist
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Write-Host "Created installation directory: $InstallDir" -ForegroundColor Green
}

# Copy entire project to installation directory
Write-Host "Copying project files to: $InstallDir" -ForegroundColor Green
Copy-Item "$ScriptDir\*" $InstallDir -Recurse -Force
Write-Host "Successfully copied all project files" -ForegroundColor Green

Write-Host "Creating startup task: $TaskName" -ForegroundColor Green
Write-Host "Script location: $MainScriptPath" -ForegroundColor Gray

# Register-ScheduledTask, schtasks with BootTrigger, all require admin rights. We try not to require admin rights. We could also `copy "startup.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"`.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" /d "PowerShell.exe -ExecutionPolicy Bypass -File `"$MainScriptPath`""

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully registered startup task" -ForegroundColor Green
    Write-Host "The application will start automatically on next login" -ForegroundColor Yellow
# Start the application immediately (don't wait for next login)
Write-Host "Starting application..." -ForegroundColor Green
Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "`"$MainScriptPath`"" -WindowStyle Hidden
Write-Host "Application started successfully" -ForegroundColor Green
} else {
    throw "Failed to register startup task (exit code: $LASTEXITCODE)"
}
