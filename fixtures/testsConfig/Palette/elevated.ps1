<#
.NOTES
Elevated = true
#>
param(
    [string]$project,
    [string]$projectPath
)

Write-Host "📤" # See "simple write...": printing it in "spawning..." will test if we have such a powershell version *in DevModeConfig*

$testFile = Join-Path . "pester-$project.txt" # Not in $env:TEMP because the environment here... is the admin's, while the file's existence will be checked in the Pester runner's user.
"Test executed at $(Get-Date)" | Out-File -FilePath $testFile -Encoding UTF8
Write-Host "Test file created: $testFile"
