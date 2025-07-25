param(
    [switch]$Force  # Pass-through the Force parameter to Uninstall.ps1
)

$ErrorActionPreference = "Stop"

# Define installation directory (must match Uninstall.ps1)
$InstallDir = "$env:LOCALAPPDATA\wProjectDesktop"

Write-Host "If wProjectDesktop is currently running, please close the command palette (focus it, then Alt+F4) then exit 'wProjectDesktop.ahk' (in the system tray, right-click, exit). Then press Enter to uninstall." -NoNewLine
Read-Host

# Check if Uninstall.ps1 exists
$UninstallScript = "$InstallDir\src\Start-Uninstall.ps1"
if (-not (Test-Path $UninstallScript)) {
    Write-Host "Uninstall script not found at: $UninstallScript" -ForegroundColor Red
    Write-Host "wProjectDesktop may not be installed or already removed" -ForegroundColor Yellow
    exit 1
}

# Copy Uninstall.ps1 to a temporary location
$TempUninstallScript = "$env:TEMP\wProjectDesktop_Uninstall_$([System.Guid]::NewGuid()).ps1"
try {
    Copy-Item -Path $UninstallScript -Destination $TempUninstallScript -Force
    Write-Host "Copied uninstall script to temporary location" -ForegroundColor Gray
} catch {
    Write-Host "Failed to copy uninstall script to temp directory" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Execute the copied uninstall script with the Force parameter if provided
try {
    if ($Force) {
        & $TempUninstallScript -Force
    } else {
        & $TempUninstallScript
    }
} catch {
    Write-Host "Error during uninstall execution: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Clean up the temporary script
    if (Test-Path $TempUninstallScript) {
        Remove-Item $TempUninstallScript -Force -ErrorAction SilentlyContinue
        Write-Host "Cleaned up temporary uninstall script" -ForegroundColor Gray
    }
}

Write-Host "Uninstall process completed" -ForegroundColor Green
