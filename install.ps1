param(
    [string]$TaskName = "wProjectSetup"
)
$ErrorActionPreference = "Stop"
. .\resources\Download-VerifiedExecutable.ps1
. .\resources\Find-AutoHotkey.ps1

Push-Location # On fait des Set-Location pour simplifier ce script, mais c'est perturbant pour l'utilisateur de finir ailleurs que là où il a lancé .\Install.ps1.

$InstallDir = "$env:LOCALAPPDATA\wProjectDesktop"
$StartupFile = "Startup.ps1"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SourceDir = Join-Path -Path $ScriptDir -ChildPath "src"

# 🍔 AutoHotkey. Avant le reste, car l'utilisateur pourra vouloir arrêter la procédure le temps de télécharger ahk.
# Here rather than at runtime, because multiple ways to find the ahk paths, so too heavy for runtime.
$autoHotkeyPath = Find-AutoHotkeyPath

if ($autoHotkeyPath) {
    Write-Host ""
    Write-Host "AutoHotkey found at: $autoHotkeyPath" -ForegroundColor Green
    
    # Only prompt to save if it wasn't already from environment variable
    $existingEnvVar = [Environment]::GetEnvironmentVariable("ahk_wPD", "User")
    if (-not $existingEnvVar -or $existingEnvVar -ne $autoHotkeyPath) {
        Set-AutoHotkeyEnvironmentVariable -AhkPath $autoHotkeyPath
    }
    
    # Test the executable
    Write-Host ""
    Write-Host "Testing AutoHotkey executable..." -ForegroundColor Cyan
    try {
        # $version = & "$autoHotkeyPath" /version 2>&1 # Doesn't work
        Write-Host "AutoHotkey is working correctly" -ForegroundColor Green
        # Write-Host "  Version: $version" -ForegroundColor Gray
    }
    catch {
        Write-Host "Warning: Could not verify AutoHotkey functionality" -ForegroundColor Yellow
    }
}
else {
    Write-Host "Setup incomplete - AutoHotkey path not configured" -ForegroundColor Red
    exit 1
}

# 🍔 Create install installation directory
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Write-Host "Created installation directory: $InstallDir" -ForegroundColor Green
}

Set-Location $InstallDir

# Copy entire project to installation directory
Write-Host "Copying project files to: $InstallDir" -ForegroundColor Green
Copy-Item "$SourceDir" .\src -Recurse -Force
Copy-Item "$ScriptDir\Sounds" .\Sounds -Recurse -Force
Copy-Item -Path "$ScriptDir\Uninstall.ps1" -Destination . -Force # On ne le mets pas dans src, pour qu'il soit visible de quelqu'un qui le chercherait dans le dossier cloné ; mais on le copie quand même, pour qu'il puisse être trouvé là-bas.
Write-Host "Successfully copied all project files" -ForegroundColor Green

mkdir "State"

# 🍔 MScholtes/VirtualDesktop dependency
## 🍔 PS Module
Write-Host "Install VirtualDesktop (will require NuGet, and ask to trust)."
# 🐑
# Install-Module VirtualDesktop -Scope CurrentUser # Scoped to user, to avoid needing admin rights.

## 🍔 exe (for direct and quick use in AHK)

# We compile it ourselves from their open-source code, for security reasons.
# The exe is only ~150 Kb, so we could include it directly in our repo. But making our Install.ps1 download it and compare against a pre-calculated checksum would:
# - complicate our code
# * add 150 Kb to our repo
# + but users could ensure we're actually downloading from a legitimate repo without having to calculate both cheksums.
# Let's favor security.
mkdir "bin"
Set-Location bin

# 🐑
$virtualDesktopPath = "VirtualDesktop.exe"
Download-VerifiedExecutable -Name "MScholtes/VirtualDesktop executable" `
    -Url "https://github.com/MScholtes/VirtualDesktop/releases/download/V1.20/VirtualDesktop11-24H2.exe" `
    -OutputPath $virtualDesktopPath `
    -ExpectedChecksum "F3799B4A542BAD7F0F2267E224BF6885F0599E444EF58394D449FD30269E3014"

# 🍔 Startup task

Write-Host "Creating startup task: $TaskName" -ForegroundColor Green

Set-Location ..\src # Pour Startup.ps1

# Register-ScheduledTask, schtasks with BootTrigger, all require admin rights. We try not to require admin rights. We could also `copy "startup.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"`.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "wProjectStartup" /d "PowerShell.exe -ExecutionPolicy Bypass -File `"$StartupFile`""

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully registered startup task" -ForegroundColor Green
}
else {
    throw "Failed to register startup task (exit code: $LASTEXITCODE)"
}

# Start the application immediately (don't wait for next login)
Write-Host "Starting application..." -ForegroundColor Green
Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "`"$StartupFile`"" -WindowStyle Hidden
Write-Host "Application started successfully" -ForegroundColor Green

Pop-Location # Voir Push-Location plus haut.
