function Download-VerifiedExecutable {
    param(
        [string]$Name,
        [string]$Url,
        [string]$OutputPath,
        [string]$ExpectedChecksum # Compile from source ; Get-FileHash -Algorithm SHA256 -Path 🦐.exe
    )
    
    Write-Host "Downloading $Name..."
    try {
        Invoke-WebRequest $Url -OutFile $OutputPath
    } catch {
        Write-Error "Failed to download $Name. Error: $($_.Exception.Message)"
        throw
    }
    
    Write-Host "Verifying checksum for $OutputPath..."
    $actualChecksum = (Get-FileHash -Algorithm SHA256 -Path $OutputPath).Hash.ToLowerInvariant()
    
    If ($actualChecksum -eq $ExpectedChecksum.ToLowerInvariant()) {
        Write-Host "Checksum verified successfully."
        Write-Host "$Name installed to $OutputPath"
    } Else {
        Write-Error "CHECKSUM MISMATCH! Expected '$ExpectedChecksum', but got '$actualChecksum'."
        Write-Error "The downloaded file might be corrupted or tampered with. Deleting the file."
        Remove-Item $OutputPath -ErrorAction SilentlyContinue
        throw "Dependency verification failed for $Name."
    }
}
