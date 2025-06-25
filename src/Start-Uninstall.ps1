param(
    [switch]$Force  # Skip confirmation prompts
)

$ErrorActionPreference = "Stop"

# Define installation directory
$InstallDir = "$env:LOCALAPPDATA\wProjectDesktop"

Write-Host "wProjectDesktop Uninstaller" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

# Check if installation exists
if (-not (Test-Path $InstallDir)) {
    Write-Host "Installation directory not found: $InstallDir" -ForegroundColor Yellow
    Write-Host "wProjectDesktop may not be installed or already removed" -ForegroundColor Yellow
} else {
    # Show what will be removed
    Write-Host "Installation found at: $InstallDir" -ForegroundColor Gray
    
    if (-not $Force) {
        $confirm = Read-Host "Remove installation directory and all files? (y/N)"
        if ($confirm -notmatch "^[Yy]") {
            Write-Host "Uninstall cancelled" -ForegroundColor Yellow
            exit 0
        }
    }
    
    try {
        Remove-Item $InstallDir -Recurse -Force
        Write-Host "Removed installation directory" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not remove some files in $InstallDir" -ForegroundColor Yellow
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Remove startup registry entry
Write-Host "Removing startup registry entry..." -ForegroundColor Gray
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" /f 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Removed startup registry entry" -ForegroundColor Green
} else {
    Write-Host "Startup registry entry not found (may already be removed)" -ForegroundColor Yellow
}

# Remove scheduled task (if it exists)
Write-Host "Checking for scheduled task..." -ForegroundColor Gray
schtasks /query /tn "\wProjectDesktop\wProjectDesktop_Startup" 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Scheduled task found. Removing (requires admin)..." -ForegroundColor Yellow
    $command = "schtasks /delete /tn `"\wProjectDesktop\wProjectDesktop_Startup`" /f"
    Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-Command", $command
    Write-Host "Admin prompt opened. Please complete the task deletion." -ForegroundColor Yellow
} else {
    Write-Host "Scheduled task not found (may already be removed)" -ForegroundColor Yellow
}

Write-Host "Uninstall completed" -ForegroundColor Green
Write-Host "Note: Any running wProjectDesktop processes must be manually terminated"
