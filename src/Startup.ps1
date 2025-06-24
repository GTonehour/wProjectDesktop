	Set-Location $PSScriptRoot # Si wPD_Run_From_Source, peut différer de $env:LocalAppData\wProjectDesktop
	Set-Location ..
& $env:ahk_wPD .\src\hotkey.ahk
. .\src\New-Project.ps1
. .\src\Show-Term.ps1
$configuredProjects = $ProjectConfigs.Keys
$LastDesktop = Get-CurrentDesktop
Get-DesktopList | Where-Object { $configuredProjects -contains $_.Name } | foreach {
	Switch-Desktop -Desktop $_.Name
	# Tourne infiniement parfois ?!
	# Puisque $_ n'est pas un desktop object, apparemment

    New-Project $_.Name
	Start-Sleep 1.5 # For the program to open before switching to the next desktop... 1/2 (Thunderbird)
}
Switch-Desktop $LastDesktop # Windows starts on the desktop that was used when it was shutdown. We don't want to change the behaviour. Setting up desktops force us to switch to them but after that, back to the one where the user was.

# & "VirtualDesktop.exe /Animation:0" # Ne fonctionne pas ET semble faire une grave memory leak...

# Windows semble persister les virtual desktops au reboot. Donc je ne les crée qu'une fois au début, dans 'win..ps1'.

# Switch-Desktop -Desktop "docs" # Ce sera le plus utilisé. Mais voyons si Windows se souvient que j'étais dessus en quittant.
. .\src\Start-Term.ps1
