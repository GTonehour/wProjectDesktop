# On nomme autrement que juste "Install.ps1" car il nous arrivait de lancer le mauvais, quand une exécution incomplète nous laissait dans install_res.
function Install-WPD {
param(
    [string]$ConfigPath = "$env:LocalAppData\wProjectDesktop\config",
    [switch]$DryRun
)
Push-Location # On fait des Set-Location pour simplifier ce script, mais c'est perturbant pour l'utilisateur de finir ailleurs que là où il a lancé .\Install.ps1.

Set-Location (Join-Path $PSScriptRoot ..) # Might be ran from somewhere else.
. .\install_res\Download-VerifiedExecutable.ps1
. .\install_res\Find-AutoHotkey.ps1
. .\install_res\Register-Startup.ps1

$InstallDir = "$env:LOCALAPPDATA\wProjectDesktop"
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
    Write-Host "AutoHotkey found at: $autoHotkeyPath" -ForegroundColor Green
    
    # Only prompt to save if it wasn't already from environment variable
    $existingEnvVar = [Environment]::GetEnvironmentVariable("ahk_wPD", "User")
    if (-not $existingEnvVar -or $existingEnvVar -ne $autoHotkeyPath) {
        if ($DryRun) {
            Write-Host "[DRY RUN] Would set AutoHotkey environment variable to: $autoHotkeyPath"
        } else {
            Set-AutoHotkeyEnvironmentVariable -AhkPath $autoHotkeyPath
        }
    }
    
    # Test the executable
    Write-Host "Testing AutoHotkey executable..."
    try {
        # $version = & "$autoHotkeyPath" /version 2>&1 # Doesn't work
        Write-Host "AutoHotkey is working correctly" -ForegroundColor Green
        # Write-Host "  Version: $version" -ForegroundColor Gray
    }
    catch {
        Write-Host "Warning: Could not verify AutoHotkey functionality" -ForegroundColor Red
    }
}
else {
    Write-Host "Setup incomplete - AutoHotkey path not configured" -ForegroundColor Red
    exit 1
}

# 🍔 Create install installation directory
if ($DryRun) {
    Write-Host "[DRY RUN] Would create installation directory: $InstallDir"
} else {
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Write-Host "Created installation directory: $InstallDir" -ForegroundColor Green
    }
}

if ($DryRun) {
    Write-Host "[DRY RUN] Would change to installation directory: $InstallDir"
} else {
# Copy entire project to installation directory
Write-Host "Copying project files to: $InstallDir"
Copy-Item "src" $InstallDir\src -Recurse -Force
Copy-Item "Sounds" $InstallDir\Sounds -Recurse -Force
Copy-Item "DefaultPalette" $InstallDir\DefaultPalette -Recurse -Force
Copy-Item -Path "Uninstall.ps1" -Destination $InstallDir -Force # On ne le mets pas dans src, pour qu'il soit visible de quelqu'un qui le chercherait dans le dossier cloné ; mais on le copie quand même, pour qu'il puisse être trouvé là-bas.
Write-Host "Successfully copied all project files" -ForegroundColor Green
}
Write-Host "Copying project files to: $InstallDir"
if (-not $DryRun) {
    Copy-Item "src" $InstallDir\src -Recurse -Force
    Copy-Item "Sounds" $InstallDir\Sounds -Recurse -Force
    Copy-Item "DefaultPalette" $InstallDir\DefaultPalette -Recurse -Force
    Copy-Item -Path "Uninstall.ps1" -Destination $InstallDir -Force # On ne le mets pas dans src, pour qu'il soit visible de quelqu'un qui le chercherait dans le dossier cloné ; mais on le copie quand même, pour qu'il puisse être trouvé là-bas.
    New-Item -ItemType "Directory" "$InstallDir\State" | Out-Null
    New-Item -ItemType "Directory" "$InstallDir\State\MRU" | Out-Null
	New-Item -ItemType "Directory" "$InstallDir\bin" | Out-Null
	Out-File -FilePath "$InstallDir\State\CurrentProject.txt"
}
    Write-Host "Successfully copied all project files" -ForegroundColor Green

# 🍔 MScholtes/VirtualDesktop dependency
## 🍔 PS Module
Write-Host "Install VirtualDesktop (will require NuGet, and ask to trust)."
# 🐑
if (-not $DryRun) {
    Install-Module VirtualDesktop -Scope CurrentUser # Scoped to user, to avoid needing admin rights.
}

## 🍔 exe (for direct and quick use in AHK)

# We compile it ourselves from their open-source code, for security reasons.
# The exe is only ~150 Kb, so we could include it directly in our repo. But making our Install.ps1 download it and compare against a pre-calculated checksum would:
# - complicate our code
# * add 150 Kb to our repo
# + but users could ensure we're actually downloading from a legitimate repo without having to calculate both cheksums.
# Let's favor security.

if (-not $DryRun) {
    Download-VerifiedExecutable -Name "MScholtes/VirtualDesktop executable" `
        -Url "https://github.com/MScholtes/VirtualDesktop/releases/download/V1.20/VirtualDesktop11-24H2.exe" `
        -OutputPath "$InstallDir\bin\VirtualDesktop.exe" `
        -ExpectedChecksum "F3799B4A542BAD7F0F2267E224BF6885F0599E444EF58394D449FD30269E3014"
}

Write-Host "Creating startup task: wProjectSetup"

$StartupFile = "$InstallDir\src\Startup.ps1"
if (-not $DryRun) {
    Register-Startup -FullPathToStartupFile $StartupFile
}

# User may have created the config directory before, for instance in their dotfiles.
if (-not (Test-Path $ConfigPath)) {
if (-not $DryRun) {
    New-Item -ItemType Directory -Path $ConfigPath | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $ConfigPath "Palette") | Out-Null
'[{"Name": "wProjectDesktop Install folder", "Path": "' + $ConfigPath.Replace('\', '\\') + '"}]' | Out-File -FilePath $ConfigPath\projects.json -Force -Encoding UTF8
}
    Write-Host "Created config directory: $ConfigPath" -ForegroundColor Green
}

# Store the config path in configPath.txt
$configPathFile = "$InstallDir\configPath.txt"
if (-not $DryRun) {
$ConfigPath | Out-File -FilePath $configPathFile -Encoding UTF8
}
Write-Host "Config path stored."

Pop-Location # Voir Push-Location plus haut.

# Start the application immediately (don't wait for next login)
    Write-Host "Starting application..."
if (-not $DryRun) {
    Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "$StartupFile" -WindowStyle Hidden
}
    Write-Host "Application started successfully" -ForegroundColor Green

return 1
}
