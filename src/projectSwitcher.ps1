. $PSScriptRoot\Show-Term.ps1
. $PSScriptRoot\New-Project.ps1 # Absolu
. $PSScriptRoot\ProjectUtils.ps1

$projectList = Get-ProjectList

$openedDesktops = Get-DesktopList | Select-Object -ExpandProperty Name

$projectList = $projectList | ForEach-Object {
    $_ | Add-Member -NotePropertyName Opened -NotePropertyValue ($openedDesktops -contains $_.Name) -PassThru
} | ForEach-Object {
    if ($_.Opened) {
        $newName = "*$($_.Name)"
    } else {
        $newName = $_.Name
    }
    $_ | Add-Member -NotePropertyName newName -NotePropertyValue $newName -PassThru
}

$selection = $projectList |
    Sort-Object -Property @{Expression="Opened"; Descending=$true}, @{Expression="Name"} |
    Select-Object -ExpandProperty newName |
    fzf.exe --prompt "Open project " # J'enlève le "--bind one:accept". En particulier à l'intallation il n'y avait que le seul projet "config", donc le choix du projet y emmenait avant d'avoir montré ce (seul) choix.

if (-not [string]::IsNullOrEmpty($selection)) { # Si on a fait échap, ne faisons rien d'autre.
    $project = $projectList | Where-Object { $_.newName -eq $selection }
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
