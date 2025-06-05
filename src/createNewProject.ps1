cls # Pour effacer le "Executing"
Write-Host "Project name: " -NoNewLine
$newProject = Read-Host
mkdir ..\$newProject
New-Desktop | Set-DesktopName -Name $newProject
Switch-Desktop -Desktop $newProject
& $env:ahk_wPD "$env:LOCALAPPDATA\wProjectDesktop\src\focusTermStandalone.ahk"
