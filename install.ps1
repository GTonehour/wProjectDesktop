param(
    [string]$TaskName = "wProjectSetup"
)

$ErrorActionPreference = "Stop"

$InstallDir = "$env:LOCALAPPDATA\wProjectDesktop"
$StartupFile = "Startup.ps1"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Create installation directory if it doesn't exist
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Write-Host "Created installation directory: $InstallDir" -ForegroundColor Green
}

Set-Location $InstallDir

# Copy entire project to installation directory
Write-Host "Copying project files to: $InstallDir" -ForegroundColor Green
Copy-Item "$ScriptDir\*" . -Recurse -Force
Write-Host "Successfully copied all project files" -ForegroundColor Green

mkdir "State"

# MScholtes/VirtualDesktop dependency
# We compile it ourselves from their open-source code, for security reasons.
# The exe is only ~150 Kb, so we could include it directly in our repo. But making our Install.ps1 download it and compare against a pre-calculated checksum would:
# - complicate our code
# * add 150 Kb to our repo
# + but users could ensure we're actually downloading from a legitimate repo without having to calculate both cheksums.
# Let's favor security.
mkdir "bin"
$outFile = Join-Path "bin" "VirtualDesktop.exe"
Write-Host "Downloading MScholtes/VirtualDesktop executable..."
try {
	Invoke-WebRequest https://github.com/MScholtes/VirtualDesktop/releases/download/V1.20/VirtualDesktop11-24H2.exe -OutFile $outFile
} catch {
	Write-Error "Failed to download VirtualDesktop.exe. Error: $($_.Exception.Message)"
}
Write-Host "Verifying checksum for $outFile..."
$actualChecksum = (Get-FileHash -Algorithm SHA256 -Path $outFile).Hash.ToLowerInvariant()
# 🦐
# Compile from source
# Get-FileHash -Algorithm SHA256 -Path .\bin\VirtualDesktop.exe
$expectedChecksum = 'F3799B4A542BAD7F0F2267E224BF6885F0599E444EF58394D449FD30269E3014'
If ($actualChecksum -eq $expectedChecksum.ToLowerInvariant()) {
    Write-Host "Checksum verified successfully."
    Write-Host "VirtualDesktop.exe installed to $outFile"
} Else {
    Write-Error "CHECKSUM MISMATCH! Expected '$expectedChecksum', but got '$actualChecksum'."
    Write-Error "The downloaded file might be corrupted or tampered with. Deleting the file."
    Remove-Item $outFile -ErrorAction SilentlyContinue
    # Throw an error to halt installation as the dependency is not secure/correct
    throw "Dependency verification failed."
}

Write-Host "Creating startup task: $TaskName" -ForegroundColor Green

# Register-ScheduledTask, schtasks with BootTrigger, all require admin rights. We try not to require admin rights. We could also `copy "startup.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"`.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" /d "PowerShell.exe -ExecutionPolicy Bypass -File `"$StartupFile`""

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully registered startup task" -ForegroundColor Green
} else {
    throw "Failed to register startup task (exit code: $LASTEXITCODE)"
}

# Start the application immediately (don't wait for next login)
Write-Host "Starting application..." -ForegroundColor Green
Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "`"$StartupFile`"" -WindowStyle Hidden
Write-Host "Application started successfully" -ForegroundColor Green

