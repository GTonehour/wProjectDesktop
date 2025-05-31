echo "Initializing wProjectDesktop..."

. .\Show-Term.ps1

$screen = Get-CimInstance -ClassName Win32_VideoController
$screenWidth = $screen.CurrentHorizontalResolution
$screenHeight = $screen.CurrentVerticalResolution
$charWidth = 8   # Adjust if needed based on your actual terminal font
$charHeight = 18  # Adjust if needed
$cols = 50 # wt s'ouvre à 50 si on précise moins
$rows = 20
$windowWidth = $cols * $charWidth
$windowHeight = $rows * $charHeight
$x = [math]::Round(($screenWidth - $windowWidth) / 2)
$y = [math]::Round(($screenHeight - $windowHeight) / 2)

wt --focus --pos $x,$y --size $cols,$rows --title PrimaryDevTerm -d "$env:LOCALAPPDATA\wProjectDesktop" powershell -File .\inProjectVirtualDesktopOpenTerminal.ps1

Start-Sleep 0.6 # 0.5/0.7 # Pas seulement dans Startup.ps1 pour attendre le premier Show-Term ; aussi quand on le restaure suite à un crash, on attend pour le WinShow qui va suivre.
# Startup.ps1: Il ne suffirait pas d'éviter (la première fois) le Hide-Term en haut de in...ps1. Car on voudrait de toute façon focus ce terminal. Certes la première fois on n'aurait pas besoin de faire l'habituel Hide+Show car on sait où on est... mais pas si sûr, car techniquement le desktop courant aurait pu bougentre le "wt" et le Show qu'on ferait ici.
Show-Term
