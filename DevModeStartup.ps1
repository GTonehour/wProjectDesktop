$stateFolder = Join-Path $PSScriptRoot State
if (-not (Test-Path $stateFolder)) {
   New-Item -Path $stateFolder -ItemType Directory -Force
}
# $devMode=$true
. $PSScriptRoot\src\Startup.ps1
