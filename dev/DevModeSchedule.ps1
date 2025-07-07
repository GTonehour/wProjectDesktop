. $PSScriptRoot\..\install_res\Register-Startup.ps1
Register-Startup $PSScriptRoot\DevMode.ps1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully registered startup task" -ForegroundColor Green
}
else {
    throw "Failed to register startup task (exit code: $LASTEXITCODE)"
}

$response = Read-Host "Run now? (y/n)"
if ($response -eq "y" -or $response -eq "yes") {
	& $PSScriptRoot\DevMode.ps1
}
