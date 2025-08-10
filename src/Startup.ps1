Set-Location (Join-Path $PSScriptRoot ..)# Si wPD_Run_From_Source, peut différer de $env:LocalAppData\wProjectDesktop

# Le trigger "LogonTrigger" s'exécute même si l'utilisateur était déjà connecté, que le terminal s'était déjà lancé, etc.
Add-Type -Path "src\WindowChecker.cs"
$termAlreadyStarted = [Win32]::WindowExists("wProjectDesktop_37")
if ($termAlreadyStarted) {
    Write-Host "Terminal already started, skipping startup initialization"
    return
}

& $env:ahk_wPD .\src\wProjectDesktop.ahk
. .\src\New-Project.ps1
. .\src\Show-Term.ps1
$configuredProjects = $ProjectConfigs.Keys

Write-Host "Initializing wProjectDesktop..." # Logging that step because this dependency sometimes runs indefinitely.
$LastDesktop = Get-CurrentDesktop
Get-DesktopList | Where-Object { $configuredProjects -contains $_.Name } | ForEach-Object {
	Switch-Desktop -Desktop $_.Name
	# Tourne infiniement parfois ?!
	# Puisque $_ n'est pas un desktop object, apparemment

    New-Project $_.Name
	Start-Sleep 2 # For the program to open before switching to the next desktop... 1.5 (Teams)/2 (Thunderbird)
}
Switch-Desktop $LastDesktop # Windows starts on the desktop that was used when it was shutdown. We don't want to change the behaviour. Setting up desktops force us to switch to them but after that, back to the one where the user was.

# & "VirtualDesktop.exe /Animation:0" # Ne fonctionne pas ET semble faire une grave memory leak...

# Windows semble persister les virtual desktops au reboot. Donc je ne les crée qu'une fois au début, dans 'win..ps1'.

# Switch-Desktop -Desktop "docs" # Ce sera le plus utilisé. Mais voyons si Windows se souvient que j'étais dessus en quittant.
. .\src\Start-Term.ps1
