$stateFolder = Join-Path $PSScriptRoot .. | Join-Path -ChildPath State
if (-not (Test-Path $stateFolder)) {
   New-Item -Path $stateFolder -ItemType Directory -Force
	Out-File -FilePath "$stateFolder\CurrentProject.txt"
}

# To prevent installing from being a prerequisite to testing.
$configFolder = Join-Path $PSScriptRoot .. | Join-Path -ChildPath devModeConfig
if (-not (Test-Path $configFolder)) {
	New-Item -Path $configFolder -ItemType Directory -Force
	New-Item -Path $configFolder\Palette -ItemType Directory -Force
	Out-File -FilePath "$configFolder\configPath.txt"
	Out-File -FilePath "$configFolder\projects.json"
}
