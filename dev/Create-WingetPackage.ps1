# Create-WingetPackage.ps1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "The version for this package, e.g., 1.0.0")]
    [string]$Version,

    [Parameter(HelpMessage = "The output directory for the ZIP file.")]
    [string]$OutDir = ".\dist"
)

# --- Configuration ---
# List all files and directories that should be included in the package.
$filesToInclude = @(
    ".gitignore",
    "install.ps1",
    "README.md",
    "Uninstall.ps1",
    "assets",
    "DefaultPalette",
    "dev",
    "devModeConfig",
    "install_res",
    "Sounds",
    "src",
    "State",
    "tests"
)

# --- Script Body ---

# Create output directory if it doesn't exist
if (-not (Test-Path -Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$archiveName = "wProjectDesktop-v$($Version).zip"
$archivePath = Join-Path -Path $OutDir -ChildPath $archiveName

# Check if the archive already exists
if (Test-Path $archivePath) {
    Write-Warning "Archive '$archivePath' already exists. It will be overwritten."
    Remove-Item $archivePath
}

Write-Host "Creating archive for version $Version at '$archivePath'..."

# Create the archive
Compress-Archive -Path $filesToInclude -DestinationPath $archivePath

$fileSize = (Get-Item $archivePath).Length
Write-Host "Archive size: $([math]::Round($fileSize / 1MB, 2)) MB"

Write-Host "Successfully created package: $archivePath"
