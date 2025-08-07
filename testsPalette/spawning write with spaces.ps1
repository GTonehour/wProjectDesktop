param(
    [string]$project,
    [string]$projectPath
)
$testFile = Join-Path $env:TEMP "pester-$project.txt"
"Test executed at $(Get-Date)" | Out-File -FilePath $testFile -Encoding UTF8
Write-Host "Test file created: $testFile"
