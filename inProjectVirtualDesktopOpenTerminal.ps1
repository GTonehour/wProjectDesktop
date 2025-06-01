function Hide-Term {
    & $env:ahk "$env:LOCALAPPDATA\wProjectDesktop\hideTermStandalone.ahk"
}
while($true){
Hide-Term
cls # Sinon on verra tous les "Executing" (et "Command failed") précédents le temps que la commande s'exécute. Pas juste avant le "executing" parce qu'on veut aussi effacer les "Not a project".
$project = Get-CurrentDesktop | Get-DesktopName # 27mai25: "FromDesktop" failed with "Object reference not set to an instance of an object." 1.5.10\VirtualDesktop.ps1:1687 char:42. A relaunch of startupDocs.ps1 fixed it.

$projectToDisplay = $project

$zoneDInteret = "$env:USERPROFILE\projects\$project"
# Notre VD a peut-être été créé manuellement ; ou peut-être qu'après Switch, le dossier a été supprimé depuis projects. Ces situations peuvent arriver : plutôt que planter, affichons un warning à côté des commandes, pour prévenir que celles qui étaient censées s'ouvrir dans le dossier ne fonctionneront pas.
Set-Location $zoneDInteret -ErrorVariable notAProject -ErrorAction SilentlyContinue
if($notAProject){
	Write-Host "'$project' isn't a project directory, some commands won't work."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	# On pensait à 💣, mais arriverait-on à l'afficher dans le terminal ?
	$projectToDisplay = "$project (no project)"
}

$wtLocated = "wt -d $zoneDInteret"
$spawnWt = "$wtLocated -p cmdLatte"
# -w $project # Si on veut nommer une fenêtre dans le but d'y ouvrir d'autres onglets. (Pour le titre, voir --title)

$wProjectDesktop = "$env:LOCALAPPDATA\wProjectDesktop"
$PowerShellCmds = @(
[PSCustomObject]@{Name = "nvim"; Cmd = "$spawnWt --title `"nvim $project`" nvim ."} # project dans le title car si on est amené à déplacer cette fenêtre dans le desktop of another project, on pourra la distinguer de son homologue local.
[PSCustomObject]@{Name = "Open recent project (switcher)"; Cmd = ". $wProjectDesktop\projectSwitcher.ps1"}
[PSCustomObject]@{Name = "neovide"; Cmd = "neovide ."}
[PSCustomObject]@{Name = "WindowsTerminal Powershell"; Cmd = "$wtLocated --title `"Terminal $project`""} # puisque powerLatte est le default profile
[PSCustomObject]@{Name = "explorer"; Cmd = "explorer ."}
[PSCustomObject]@{Name = "code"; Cmd = "code ."}
[PSCustomObject]@{Name = "lazygit"; Cmd = "$spawnWt --title `"lazygit $project`" lazygit"}
[PSCustomObject]@{Name = "yazi"; Cmd = "$spawnWt --title `"yazi $project`" yazi ."}
[PSCustomObject]@{Name = "gitk"; Cmd = "gitk --all"} # Aussi dans lazygit, 'a' dans le [1]
[PSCustomObject]@{Name = "Quick git push"; Cmd = "git add .; git commit -m `"Quick push`"; git push"}
[PSCustomObject]@{Name = "ssh port-forwarding PG"; Cmd = "$spawnWt --title `"ssh port-forwarding PG`" ssh -fNL 15432:localhost:5432 mmi@$env:VPS"} # La fenêtre va se fermer, même alors que la commande s'est bien lancée et reste active.
[PSCustomObject]@{Name = "ssh port-forward HashiCorp Vault"; Cmd = "$spawnWt --title `"ssh port-forwarding HashiCorp Vault`" ssh -NL 8200:localhost:8200 mmi@$env:VPS; Start-Process firefox -ArgumentList https://localhost:8200"} # La fenêtre va se fermer, même alors que la commande s'est bien lancée et reste active.
[PSCustomObject]@{Name = "Create new project"; Cmd = ". $wProjectDesktop\createNewProject.ps1"} # La fenêtre va se fermer, même alors que la commande s'est bien lancée et reste active.
[PSCustomObject]@{Name = "Refresh Rainmeter"; Cmd = ". `"$env:projects\docs\Keep on screen rainmeter skin refresh verif.ps1`""}
[PSCustomObject]@{Name = "verif_aff"; Cmd = "cd $env:projects\docs ; .\venv\verif\Scripts\Activate.ps1 ; py verif_aff.py ; deactivate"}
) | ForEach-Object { $_ | Add-Member -NotePropertyName "Type" -NotePropertyValue "PowerShell" -PassThru }

$BashCmds = @(
[PSCustomObject]@{Name = "git init --bare & first push"; Cmd = "$env:PROJECTS/docs/git push initialize remote bare.sh"}
) | ForEach-Object { $_ | Add-Member -NotePropertyName "Type" -NotePropertyValue "Bash" -PassThru }

$cmds = $PowerShellCmds + $BashCmds

$Name = $cmds | ForEach-Object {$_.Name} | fzf.exe --prompt "$projectToDisplay > " --bind one:accept

if (-not [string]::IsNullOrEmpty($Name)) {
    $selectedCmd = $cmds | Where-Object {$_.Name -eq $Name}
    Write-Host "``$($selectedCmd.Cmd)``..." # Rassure le temps que neovide, par exemple, s'ouvre.

	if ($selectedCmd.Type -eq "Bash") {
		# Dans un vrai terminal bash pour pouvoir faire des choses interactives, voir les messages d'erreurs, etc. Mais on remettra aussi l'autre option
		wt -p "Git Bash" --title Bash --appendCommandLine $selectedCmd.Cmd
    } elseif ($selectedCmd.Type -eq "PowerShell") {
        Invoke-Expression $selectedCmd.Cmd -ErrorVariable cmdError
        if ($cmdError) {
            Write-Host "Command failed." -ForegroundColor Red
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }

}
}
