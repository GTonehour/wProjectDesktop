$ErrorActionPreference = "Stop"
. $PSScriptRoot\install_res\InstallFunction.ps1
Install-WPD | Out-Null # On a besoin d'un return pour le test, mais pas de l'afficher
