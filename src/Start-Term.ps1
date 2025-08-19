Write-Host "Starting palette..."

. $PSScriptRoot\Show-Term.ps1

# _37 car par exemple ma fenêtre Neovide portait le seul nom du projet.
Start-WindowsTerminal -ScriptPath ".\src\PaletteStandalone.ps1" -WorkingDirectory "$PSScriptRoot\.."

Start-Sleep 0.6 # 0.5/0.7 # Pas seulement dans Startup.ps1 pour attendre le premier Show-Term ; aussi quand on le restaure suite à un crash, on attend pour le WinShow qui va suivre.
# Startup.ps1: Il ne suffirait pas d'éviter (la première fois) le Hide-Term en haut de in...ps1. Car on voudrait de toute façon focus ce terminal. Certes la première fois on n'aurait pas besoin de faire l'habituel Hide+Show car on sait où on est... mais pas si sûr, car techniquement le desktop courant aurait pu bouger entre le "wt" et le Show qu'on ferait ici.
Show-Term
