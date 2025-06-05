# cls

. $env:LOCALAPPDATA\wProjectDesktop\src\Show-Term.ps1

. $env:LOCALAPPDATA\wProjectDesktop\src\New-Project.ps1 # Absolu

# Pour créer un symlink, ouvrir PS en Admin puis `new-item -itemtype symboliclink -path C:\Users\mmi\projects -name nvim -value "$env:LOCALAPPDATA\nvim"` ($env:USERPROFILE comme path, seulement si on est cet admin en tant que qui on est connecté)
$documentsPath = "$env:USERPROFILE\projects"

$openedDesktops = Get-DesktopList | Select-Object -ExpandProperty Name

$projects = Get-ChildItem -Path "$env:USERPROFILE\projects" -Directory | foreach {
	$_ | Add-Member -NotePropertyName Opened -NotePropertyValue ($openedDesktops -contains $_.Name) -PassThru } | foreach {
		if($_.Opened){
			$newName = "*$_"
		} else {
			$newName = $_.Name
		}
		$_ | Add-Member -NotePropertyName newName -NotePropertyValue $newName -PassThru
	}
$selection = $projects |
Sort-Object -Property @{Expression="Opened"; Descending=$true}, @{Expression="Name"} |
Select-Object -ExpandProperty newName |
fzf.exe --prompt "Open project " --bind one:accept # Sélection automatique quand un seul match
if (-not [string]::IsNullOrEmpty($selection)) { # Si on a fait échap, ne faisons rien d'autre.
	$project = $projects | Where-Object { $_.newName -eq $selection }
	if(-not $project.Opened) {
		New-Desktop | Set-DesktopName -Name $project.Name
		Switch-Desktop -Desktop $project.Name
		New-Project $project.Name
		# on voudra y faire quelque chose dans ce projet, puisqu'il est nouveau
		Show-Term
	} else {
		Switch-Desktop -Desktop $project.Name
	}
}
