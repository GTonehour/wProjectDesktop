    # Method 1: Use Get-AppxPackage (works without admin)
    $whatsappPackage = Get-AppxPackage -Name "*WhatsApp*" | Where-Object { $_.Name -like "*WhatsAppDesktop*" }
    
    if ($whatsappPackage) {
        $installLocation = $whatsappPackage.InstallLocation
        $whatsappExe = Join-Path $installLocation "WhatsApp.exe"
        
        if (Test-Path $whatsappExe) {
            Write-Host "Starting WhatsApp from: $whatsappExe"
            Start-Process $whatsappExe
            return
        }
    }
    
    # Method 2: Use Windows Shell to start via App ID (fallback)
    try {
        Write-Host "Trying to start WhatsApp via Windows Shell..."
        Start-Process "shell:AppsFolder\5319275A.WhatsAppDesktop_cv1g1gvanyjgm!WhatsApp"
        return
    }
    catch {
        Write-Host "Could not start via Shell method"
    }
    
    # Method 3: Use winget to get the exact path (last resort)
    try {
        Write-Host "Trying to locate WhatsApp via winget..."
        $wingetOutput = winget list --id "9NKSQGP7F2NH" --exact 2>$null
        if ($LASTEXITCODE -eq 0) {
            # If winget found it, try the shell method again
            Start-Process "shell:AppsFolder\5319275A.WhatsAppDesktop_cv1g1gvanyjgm!WhatsApp"
            return
        }
    }
    catch {
        Write-Host "Winget method failed"
    }
    
    Write-Error "WhatsApp not found. Make sure it's installed via: winget install 9NKSQGP7F2NH"
