param(
    [string]$TaskName = "wProjectSetup",
    [string]$customConfig = ""
    [switch]$DryRun
)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot # Might be ran from somewhere else.
. .\install_res\Download-VerifiedExecutable.ps1
. .\install_res\Find-AutoHotkey.ps1
. .\install_res\Register-Startup.ps1

Push-Location # On fait des Set-Location pour simplifier ce script, mais c'est perturbant pour l'utilisateur de finir ailleurs que là où il a lancé .\Install.ps1.

$InstallDir = "$env:LOCALAPPDATA\wProjectDesktop"
$StartupFile = "Startup.ps1"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# 🍔 AutoHotkey. Avant le reste, car l'utilisateur pourra vouloir arrêter la procédure le temps de télécharger ahk.
# Here rather than at runtime, because multiple ways to find the ahk paths, so too heavy for runtime.
$autoHotkeyPath = Find-AutoHotkeyPath
if ($DryRun) {
    Write-Host "[DRY RUN] Would find AutoHotkey path" -ForegroundColor Cyan
    $autoHotkeyPath = "C:\Program Files\AutoHotkey\AutoHotkey.exe"  # Mock path for dry run
} else {
    $autoHotkeyPath = Find-AutoHotkeyPath
}

if ($autoHotkeyPath) {
    Write-Host ""
    Write-Host "AutoHotkey found at: $autoHotkeyPath" -ForegroundColor Green
    
    # Only prompt to save if it wasn't already from environment variable
    $existingEnvVar = [Environment]::GetEnvironmentVariable("ahk_wPD", "User")
    if (-not $existingEnvVar -or $existingEnvVar -ne $autoHotkeyPath) {
        if ($DryRun) {
            Write-Host "[DRY RUN] Would set AutoHotkey environment variable to: $autoHotkeyPath" -ForegroundColor Cyan
        } else {
            Set-AutoHotkeyEnvironmentVariable -AhkPath $autoHotkeyPath
        }
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
if ($DryRun) {
    Write-Host "[DRY RUN] Would create installation directory: $InstallDir" -ForegroundColor Cyan
} else {
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Write-Host "Created installation directory: $InstallDir" -ForegroundColor Green
    }
}

if ($DryRun) {
    Write-Host "[DRY RUN] Would change to installation directory: $InstallDir" -ForegroundColor Cyan
} else {
    Set-Location $InstallDir
}

# Copy entire project to installation directory
Write-Host "Copying project files to: $InstallDir" -ForegroundColor Green
Copy-Item "$ScriptDir\src" .\src -Recurse -Force
Copy-Item "$ScriptDir\Sounds" .\Sounds -Recurse -Force
Copy-Item "$ScriptDir\DefaultPalette" .\DefaultPalette -Recurse -Force
Copy-Item -Path "$ScriptDir\Uninstall.ps1" -Destination . -Force # On ne le mets pas dans src, pour qu'il soit visible de quelqu'un qui le chercherait dans le dossier cloné ; mais on le copie quand même, pour qu'il puisse être trouvé là-bas.
Write-Host "Successfully copied all project files" -ForegroundColor Green

mkdir "State"
mkdir "State\MRU"
if ($DryRun) {
    Write-Host "[DRY RUN] Would copy project files to: $InstallDir" -ForegroundColor Cyan
    Write-Host "[DRY RUN] Would copy: src, Sounds, DefaultPalette, Uninstall.ps1" -ForegroundColor Cyan
} else {
    Write-Host "Copying project files to: $InstallDir" -ForegroundColor Green
    Copy-Item "$SourceDir\src" .\src -Recurse -Force
    Copy-Item "$ScriptDir\Sounds" .\Sounds -Recurse -Force
    Copy-Item "$ScriptDir\DefaultPalette" .\DefaultPalette -Recurse -Force
    Copy-Item -Path "$ScriptDir\Uninstall.ps1" -Destination . -Force # On ne le mets pas dans src, pour qu'il soit visible de quelqu'un qui le chercherait dans le dossier cloné ; mais on le copie quand même, pour qu'il puisse être trouvé là-bas.
    Write-Host "Successfully copied all project files" -ForegroundColor Green
}

if ($DryRun) {
    Write-Host "[DRY RUN] Would create directories: State, State\MRU, Config" -ForegroundColor Cyan
} else {
    mkdir "State"
    mkdir "State\MRU"
    mkdir "Config"
}

# 🍔 MScholtes/VirtualDesktop dependency
## 🍔 PS Module
Write-Host "Install VirtualDesktop (will require NuGet, and ask to trust)."
# 🐑
if ($DryRun) {
    Write-Host "[DRY RUN] Would install VirtualDesktop PowerShell module" -ForegroundColor Cyan
} else {
    Install-Module VirtualDesktop -Scope CurrentUser # Scoped to user, to avoid needing admin rights.
}

## 🍔 exe (for direct and quick use in AHK)

# We compile it ourselves from their open-source code, for security reasons.
# The exe is only ~150 Kb, so we could include it directly in our repo. But making our Install.ps1 download it and compare against a pre-calculated checksum would:
# - complicate our code
# * add 150 Kb to our repo
# + but users could ensure we're actually downloading from a legitimate repo without having to calculate both cheksums.
# Let's favor security.
if ($DryRun) {
    Write-Host "[DRY RUN] Would create bin directory and change to it" -ForegroundColor Cyan
} else {
    mkdir "bin"
    Set-Location bin
}

# 🐑
$virtualDesktopPath = "VirtualDesktop.exe"
if ($DryRun) {
    Write-Host "[DRY RUN] Would download VirtualDesktop.exe from GitHub" -ForegroundColor Cyan
    Write-Host "[DRY RUN] Would verify checksum: F3799B4A542BAD7F0F2267E224BF6885F0599E444EF58394D449FD30269E3014" -ForegroundColor Cyan
} else {
    Download-VerifiedExecutable -Name "MScholtes/VirtualDesktop executable" `
        -Url "https://github.com/MScholtes/VirtualDesktop/releases/download/V1.20/VirtualDesktop11-24H2.exe" `
        -OutputPath $virtualDesktopPath `
        -ExpectedChecksum "F3799B4A542BAD7F0F2267E224BF6885F0599E444EF58394D449FD30269E3014"
}

# 🍔 Startup task

Write-Host "Creating startup task: $TaskName" -ForegroundColor Green

if ($DryRun) {
    Write-Host "[DRY RUN] Would change to src directory" -ForegroundColor Cyan
    Write-Host "[DRY RUN] Would register startup task: $TaskName" -ForegroundColor Cyan
} else {
    Set-Location ..\src # Pour Startup.ps1
    Register-Startup $StartupFile
}

# Start the application immediately (don't wait for next login)
if ($DryRun) {
    Write-Host "[DRY RUN] Would start application: $StartupFile" -ForegroundColor Cyan
} else {
    Write-Host "Starting application..." -ForegroundColor Green
    Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "`"$StartupFile`"" -WindowStyle Hidden
    Write-Host "Application started successfully" -ForegroundColor Green
}

# Set up custom config path
if ($customConfig) {
    $configPath = $customConfig
    Write-Host "Using custom config path: $configPath"
} else {
    $configPath = "$env:LocalAppData\wProjectDesktop\config"
    Write-Host "Using default config path: $configPath" -ForegroundColor Green
}

# Create config directory if it doesn't exist
if (-not (Test-Path $configPath)) {
    New-Item -ItemType Directory -Path $configPath | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $configPath "Palette") | Out-Null
'[{"Name": "wProjectDesktop Install folder", "Path": "' + $configPath.Replace('\', '\\') + '"}]' | Out-File -FilePath $configPath\projects.json -Force -Encoding UTF8
    Write-Host "Created config directory: $configPath" -ForegroundColor Green
}

# Store the config path in configPath.txt
$configPathFile = "$InstallDir\configPath.txt"
$configPath | Out-File -FilePath $configPathFile -Encoding UTF8
Write-Host "Config path stored in: $configPathFile" -ForegroundColor Green

Pop-Location # Voir Push-Location plus haut.
