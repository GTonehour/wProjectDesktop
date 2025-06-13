function Find-AutoHotkeyPath {
    Write-Host "Searching for AutoHotkey installation..." -ForegroundColor Cyan
    
    # 1. Check user environment variable first
    $ahkPath = [Environment]::GetEnvironmentVariable("ahk_wPD", "User")
    if ($ahkPath -and (Test-Path $ahkPath)) {
        Write-Host "Found AutoHotkey via ahk_wPD environment variable: $ahkPath" -ForegroundColor Green
        return $ahkPath
    }
    
    # 2. Registry lookup
    Write-Host "Checking Windows registry..." -ForegroundColor Yellow
    try {
        $regPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\AutoHotkey" -Name "InstallDir" -ErrorAction SilentlyContinue
        if ($regPath) {
            $ahkExe = Join-Path $regPath.InstallDir "v2\AutoHotkey.exe"
            if (Test-Path $ahkExe) {
                Write-Host "Found AutoHotkey via registry: $ahkExe" -ForegroundColor Green
                return $ahkExe
            }
        }
    }
    catch {
        Write-Host "Registry lookup failed" -ForegroundColor DarkYellow
    }
    
    # 3. PATH environment variable
    Write-Host "Checking PATH environment variable..." -ForegroundColor Yellow
    try {
        $ahkInPath = Get-Command "AutoHotkey.exe" -ErrorAction SilentlyContinue
        if ($ahkInPath) {
            Write-Host "Found AutoHotkey in PATH: $($ahkInPath.Source)" -ForegroundColor Green
            return $ahkInPath.Source
        }
    }
    catch {
        Write-Host "PATH lookup failed" -ForegroundColor DarkYellow
    }
    
    # 4. Common installation paths
    Write-Host "Checking common installation paths..." -ForegroundColor Yellow
# Determine the appropriate executable based on system architecture
if ([Environment]::Is64BitOperatingSystem) {
    $ahkExe = "AutoHotkey64.exe"
    Write-Host "Detected 64-bit system, looking for $ahkExe" -ForegroundColor Cyan
} else {
    $ahkExe = "AutoHotkey32.exe"
    Write-Host "Detected 32-bit system, looking for $ahkExe" -ForegroundColor Cyan
}
# Write-Host "Looking for $ahkExe"

$commonPaths = @(
    "${env:ProgramFiles}\AutoHotkey\$ahkExe",
    "${env:ProgramFiles(x86)}\AutoHotkey\$ahkExe",
    "${env:LOCALAPPDATA}\Programs\AutoHotkey\v2\$ahkExe"
)
    
    foreach ($path in $commonPaths) {
		# Write-Host $path
        if (Test-Path $path) {
            Write-Host "Found AutoHotkey at: $path" -ForegroundColor Green
            return $path
        }
    }

    # 5. Not found - Offer download, then prompt user
    Write-Host "AutoHotkey not found automatically" -ForegroundColor Red
    Write-Host ""
    
    # --- MODIFICATION START: Offer automatic download and install ---
    $choice = Read-Host "Download and install AutoHotkey v2 ? (Else you'll be prompted to manually enter the path to the exe file.) (y/n)"
    if ($choice -match '^(y|yes)$') {
        Write-Host "Attempting to download and install AutoHotkey v2..." -ForegroundColor Cyan
        $tempSetupFile = Join-Path $env:TEMP "ahk-v2-setup.exe" # Download to a temporary path
        
        try {
            # Ensure Download-VerifiedExecutable is defined in your script or dot-sourced
            Download-VerifiedExecutable -Name "AutoHotkey v2 Setup" `
                -Url "https://www.autohotkey.com/download/ahk-v2.exe" `
                -OutputPath $tempSetupFile `
                -ExpectedChecksum "FD55129CBD356F49D2151E0A8B9662D90D2DBBB9579CC2410FDE38DF94787A3A"

            if (Test-Path $tempSetupFile) {
                Write-Host "AutoHotkey setup downloaded successfully: $tempSetupFile" -ForegroundColor Green
                Write-Host "Attempting silent installation. This may require administrator privileges." -ForegroundColor Cyan
                
                # Silent install. /S is for silent. It will install to the default location.
                # The default location is usually C:\Program Files\AutoHotkey
                try {
                    Start-Process -FilePath $tempSetupFile -ArgumentList "/S" -Wait -Verb RunAs -ErrorAction Stop
                    Write-Host "AutoHotkey installation process completed." -ForegroundColor Green
                }
                catch {
                    Write-Host "Silent installation failed. $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host "You might need to run PowerShell as an Administrator, or the installer was cancelled." -ForegroundColor Yellow
                    Write-Host "Proceeding to manual path input." -ForegroundColor Yellow
                    # Fall through to manual input
                }

                # Brief pause to allow filesystem and registry to update
                Start-Sleep -Seconds 3 

                Write-Host "Re-scanning for AutoHotkey installation..." -ForegroundColor Cyan
                
                # Attempt to find it again using the most likely methods post-install
                # Check registry again
                $regKeyAfterInstall = Get-ItemProperty -Path "HKLM:\SOFTWARE\AutoHotkey" -ErrorAction SilentlyContinue
                if ($regKeyAfterInstall -and $regKeyAfterInstall.InstallDir) {
                    $potentialAhkPathsAfterInstall = @(
                        Join-Path $regKeyAfterInstall.InstallDir "AutoHotkey.exe",
                        Join-Path $regKeyAfterInstall.InstallDir "v2" "AutoHotkey.exe"
                    )
                    foreach ($pAfter in $potentialAhkPathsAfterInstall) {
                        if (Test-Path $pAfter) {
                            Write-Host "Found AutoHotkey via registry after installation: $pAfter" -ForegroundColor Green
                            Remove-Item $tempSetupFile -ErrorAction SilentlyContinue # Clean up installer
                            return $pAfter
                        }
                    }
                }

                # Re-Check common Program Files paths
                $commonPathsAfterInstall = @( # Focus on standard install locations
                    "${env:ProgramFiles}\AutoHotkey\AutoHotkey.exe",
                    "${env:ProgramFiles(x86)}\AutoHotkey\AutoHotkey.exe",
                    "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey.exe",
                    "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey.exe"
                )
                foreach ($pathAfter in $commonPathsAfterInstall) {
                    if (Test-Path $pathAfter) {
                        Write-Host "Found AutoHotkey at: $pathAfter after installation" -ForegroundColor Green
                        Remove-Item $tempSetupFile -ErrorAction SilentlyContinue
                        return $pathAfter
                    }
                }
                
                Write-Host "AutoHotkey may have been installed, but its path could not be automatically found." -ForegroundColor Yellow
                Write-Host "You might need to restart PowerShell for PATH changes to take effect if it was installed to a new directory in PATH." -ForegroundColor Yellow
            } else {
                Write-Host "Download function did not result in the expected file: $tempSetupFile." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Failed to download or initiate install for AutoHotkey: $($_.Exception.Message)" -ForegroundColor Red
        }
        finally {
            if (Test-Path $tempSetupFile) {
                Remove-Item $tempSetupFile -ErrorAction SilentlyContinue # Ensure cleanup
            }
        }
        # If installation was attempted but path not found, or if download/install failed/skipped, fall through to manual input.
        Write-Host "Proceeding to manual path input." -ForegroundColor Yellow
        Write-Host ""
    }
    
    # 6. Not found - prompt user
    Write-Host "AutoHotkey not found automatically" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please provide the full path to AutoHotkey.exe" -ForegroundColor White
    Write-Host "Example: C:\Program Files\AutoHotkey\AutoHotkey.exe" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Note: You can set this later in the ahk_wPD environment variable:" -ForegroundColor Cyan
    Write-Host ""
    
    do {
        $userPath = Read-Host "AutoHotkey.exe path"
        
        if ([string]::IsNullOrWhiteSpace($userPath)) {
            Write-Host "Path cannot be empty. Please try again." -ForegroundColor Red
            continue
        }
        
        if (Test-Path $userPath) {
            Write-Host "Path verified: $userPath" -ForegroundColor Green
            return $userPath
        }
        else {
            Write-Host "File not found at: $userPath" -ForegroundColor Red
            Write-Host "Please check the path and try again." -ForegroundColor Yellow
        }
    } while ($true)
}

function Set-AutoHotkeyEnvironmentVariable {
    param([string]$AhkPath)
    
    Write-Host "Path saved to ahk_wPD. You can change that environment variable later to use another AutoHotkey executable."
    
        try {
            [Environment]::SetEnvironmentVariable("ahk_wPD", $AhkPath, "User")
            Write-Host "Environment variable ahk_wPD set successfully" -ForegroundColor Green
            Write-Host "  This will be available in new PowerShell sessions" -ForegroundColor Gray
        }
        catch {
            Write-Host "Failed to set environment variable: $($_.Exception.Message)" -ForegroundColor Red
        }
}
