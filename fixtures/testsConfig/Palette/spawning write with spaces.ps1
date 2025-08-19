param(
    [string]$project,
    [string]$projectPath
)

Write-Host "📤" # See "simple write...": printing it in "spawning..." will test if we have such a powershell version *in DevModeConfig*

$testFile = Join-Path $env:TEMP "pester-$project.txt"
"Test executed at $(Get-Date)" | Out-File -FilePath $testFile -Encoding UTF8
Write-Host "Test file created: $testFile"
