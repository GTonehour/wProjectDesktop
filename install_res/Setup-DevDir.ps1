$stateFolder = Join-Path $PSScriptRoot .. State
if (-not (Test-Path $stateFolder)) {
   New-Item -Path $stateFolder -ItemType Directory -Force
	Out-File -FilePath "$stateFolder\CurrentProject.txt"
}
