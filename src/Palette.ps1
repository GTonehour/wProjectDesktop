$ErrorActionPreference = "Stop" # Sinon quand plante après installation, par exemple pour une question d'exécutable autohotkey, affiche le fzf comme si de rien était mais sans pouvoir se Hide ni fonctionner.

$wProjectDesktop=(Join-Path $PSScriptRoot "..")
function Hide-Term {
    & $env:ahk_wPD "$PSScriptRoot\hideTermStandalone.ahk"
}

. $PSScriptRoot\ProjectUtils.ps1

while($true){
    if(-Not $keepOpened){
        Hide-Term
    }
    $keepOpened=$false
    cls # Sinon on verra tous les "Executing" (et "Command failed") précédents le temps que la commande s'exécute. Pas juste avant le "executing" parce qu'on veut aussi effacer les "Not a project".
    $project = Get-CurrentDesktop | Get-DesktopName # 27mai25: "FromDesktop" failed with "Object reference not set to an instance of an object." 1.5.10\VirtualDesktop.ps1:1687 char:42. A relaunch of startupDocs.ps1 fixed it.
    $projectList = Get-ProjectList
    $projectObj = $projectList | Where-Object { $_.Name -eq $project }
    if ($projectObj) {
        $projectPath = $projectObj.Path
        Set-Location $projectPath -ErrorVariable notAProject -ErrorAction SilentlyContinue
        if ($notAProject) {
            $projectPath = $env:USERPROFILE
            Set-Location $projectPath
            $projectToDisplay = "$project (invalid project path)"
        } else {
            $projectToDisplay = $project
        }
    } else {
        # Notre VD a peut-être été créé manuellement ; ou peut-être qu'après Switch, le dossier a été supprimé depuis projects. Ces situations peuvent arriver : plutôt que planter, affichons un warning à côté des commandes, pour prévenir que celles qui étaient censées s'ouvrir dans le dossier ne fonctionneront pas.
        $projectPath = $env:USERPROFILE
        Set-Location $projectPath
        # Write-Host "'$project' isn't a project directory, some commands won't work."
        #    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        # On pensait à 💣, mais arriverait-on à l'afficher dans le terminal ?
        $projectToDisplay = "$project (no project)"
    }

    $wtLocated = "wt -d $projectPath"
    $spawnWt = "$wtLocated -p cmdLatte"
    # -w $project # Si on veut nommer une fenêtre dans le but d'y ouvrir d'autres onglets. (Pour le titre, voir --title)

    $PowerShellCmds = @(
        [PSCustomObject]@{Name = "nvim"; Cmd = "$spawnWt --title `"nvim $project`" nvim ."} # project dans le title car si on est amené à déplacer cette fenêtre dans le desktop of another project, on pourra la distinguer de son homologue local.
        [PSCustomObject]@{Name = "Open recent project (switcher)"; Cmd = ". $PSScriptRoot\projectSwitcher.ps1"}
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
        [PSCustomObject]@{Name = "Create new project"; Cmd = ". $PSScriptRoot\createNewProject.ps1"} # La fenêtre va se fermer, même alors que la commande s'est bien lancée et reste active.
        [PSCustomObject]@{Name = "Refresh Rainmeter"; Cmd = ". `"$env:projects\docs\Keep on screen rainmeter skin refresh verif.ps1`""}
        [PSCustomObject]@{Name = "verif_aff"; Cmd = "cd $env:projects\docs ; .\venv\verif\Scripts\Activate.ps1 ; py verif_aff.py ; deactivate"}
        [PSCustomObject]@{Name = "WSL"; Cmd = "$wtLocated -p Ubuntu --title WSL"}
        [PSCustomObject]@{Name = "Claude Code"; Cmd = "$spawnWt --title `"Claude Code`" wsl bash -i -c `"claude`""}
    ) | ForEach-Object { $_ | Add-Member -NotePropertyName "Type" -NotePropertyValue "PowerShell" -PassThru }

    $BashCmds = @(
        [PSCustomObject]@{Name = "git init --bare & first push"; Cmd = "$env:PROJECTS/docs/git push initialize remote bare.sh"}
    ) | ForEach-Object { $_ | Add-Member -NotePropertyName "Type" -NotePropertyValue "Bash" -PassThru }

    $cmds = $PowerShellCmds + $BashCmds

    $switchedKey = 'f12'

    # 1. Pas trop avant le fzf sinon si on était sur A puis qu'on va sur B jusqu'au changement d'état et qu'on va sur C (pouvant être A) avant le fzf, "Esc" pourrait envoyé dans le vide et donc rester incohérent.
    # 2. Pas trop après sinon si on était sur A puis qu'on va jusqu'au fzf sur B et qu'on revient sur A avant que l'état soit sur B, l'état restera incohérent.
    # Dans les deux cas on peut rester dans un état incohérent. Certes le scénario le moins probable est le 2 (car suppose A->B->A plutôt que A->B->CdontA), MAIS on préfère avoir un state pour le tout premier après Startup.
    Set-Content -Path $wProjectDesktop\State\CurrentProject.txt -Value $project -NoNewline

    $Name = $cmds | ForEach-Object {$_.Name} | fzf.exe --prompt "$projectToDisplay > " --bind one:accept --cycle --expect=$switchedKey

    if ($Name.Count -eq 2) { # Aura toujours deux valeurs (0 si on a escaped), à cause de mon expect. Mais la première ne sera remplie (de switchedKey) que si j'ai appuyé cette dernière.
        if ($Name[0] -eq $switchedKey) {
            $keepOpened=$true
        } else {
            $selectedCmd = $cmds | Where-Object {$_.Name -eq $Name[1]}
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
}
