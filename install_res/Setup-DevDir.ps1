$stateFolder = Join-Path $PSScriptRoot .. | Join-Path -ChildPath State
if (-not (Test-Path $stateFolder)) {
   New-Item -Path $stateFolder -ItemType Directory -Force
   New-Item -Path $stateFolder\MRU -ItemType Directory -Force
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

# We may want F1 to run the script in $env:localappdata\wProjectDesktop, or in our local folder. Register-Startup will store which one we want in $localappdata\wProjectDesktop. Why there: because where else would we tell the ahk script to look?
$wpdDir = "$env:LocalAppData\wProjectDesktop"
if (-not (Test-Path $wpdDir)) {
	New-Item -Path $wpdDir -ItemType Directory -Force
}
