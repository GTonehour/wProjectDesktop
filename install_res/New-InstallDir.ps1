function New-InstallDir {
    param(
        [bool]$DryRun,
        [string]$InstallDir
    )
    
    . $PSScriptRoot\Get-VerifiedExecutable.ps1

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create installation directory: $InstallDir"
    } else {
        if (-not (Test-Path $InstallDir)) {
            New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
            Write-Host "Created installation directory: $InstallDir" -ForegroundColor Green
            New-Item -ItemType "Directory" "$InstallDir\bin" | Out-Null
            ## exe (for direct and quick use in AHK)
    
            # We compile it ourselves from their open-source code, for security reasons.
            # The exe is only ~150 Kb, so we could include it directly in our repo. But making our Install.ps1 download it and compare against a pre-calculated checksum would:
            # - complicate our code
            # * add 150 Kb to our repo
            # + but users could ensure we're actually downloading from a legitimate repo without having to calculate both cheksums.
            # Let's favor security.
            Get-VerifiedExecutable -Name "MScholtes/VirtualDesktop executable" `
                -Url "https://github.com/MScholtes/VirtualDesktop/releases/download/V1.20/VirtualDesktop11-24H2.exe" `
                -OutputPath "$InstallDir\bin\VirtualDesktop.exe" `
                -ExpectedChecksum "F3799B4A542BAD7F0F2267E224BF6885F0599E444EF58394D449FD30269E3014"
        }
    }
}