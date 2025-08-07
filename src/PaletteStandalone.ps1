$ErrorActionPreference = "Stop" # Sinon quand plante après installation, par exemple pour une question d'exécutable autohotkey, affiche le fzf comme si de rien était mais sans pouvoir se Hide ni fonctionner.

. $PSScriptRoot\Palette.ps1
Show-Palette
