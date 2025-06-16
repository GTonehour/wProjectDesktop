$ErrorActionPreference = "Stop" # Sinon quand plante après installation, par exemple pour une question d'exécutable autohotkey, affiche le fzf comme si de rien était mais sans pouvoir se Hide ni fonctionner.

$wProjectDesktop=(Join-Path $PSScriptRoot "..")
function Hide-Term {
    & $env:ahk_wPD "$PSScriptRoot\hideTermStandalone.ahk"
}

. $PSScriptRoot\ProjectUtils.ps1

function Update-MRU {
    param([string]$ScriptName)
    $mruPath = Join-Path $wProjectDesktop "State\MRU\$ScriptName.txt"
    Set-Content -Path $mruPath -Value (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') -NoNewline
}

function Get-MRUTimestamp {
    param([string]$ScriptName)
    $mruPath = Join-Path $wProjectDesktop "State\MRU\$ScriptName.txt"
    if (Test-Path $mruPath) {
        return [DateTime]::Parse((Get-Content $mruPath))
    }
    return $null
}

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

    # Load commands from DefaultPalette folder
    $defaultPalettePath = Join-Path $wProjectDesktop "DefaultPalette"
    $cmds = @()
    
    if (Test-Path $defaultPalettePath) {
        $scriptFiles = Get-ChildItem -Path $defaultPalettePath -File
        
        foreach ($file in $scriptFiles) {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $extension = $file.Extension.ToLower()
            
            if ($extension -eq ".ps1") {
                $mruTimestamp = Get-MRUTimestamp -ScriptName $name
                $cmds += [PSCustomObject]@{
                    Name = $name
                    ScriptPath = $file.FullName
                    Type = "PowerShell"
                    MRUTimestamp = $mruTimestamp
                }
            } elseif ($extension -eq ".sh") {
                $mruTimestamp = Get-MRUTimestamp -ScriptName $name
                $cmds += [PSCustomObject]@{
                    Name = $name
                    ScriptPath = $file.FullName
                    Type = "Bash"
                    MRUTimestamp = $mruTimestamp
                }
            }
        }
        
        # Sort commands: MRU first (most recent first), then alphabetically for untracked
        $cmds = $cmds | Sort-Object @{
            Expression = { if ($_.MRUTimestamp) { 0 } else { 1 } }
        }, @{
            Expression = { if ($_.MRUTimestamp) { -$_.MRUTimestamp.Ticks } else { 0 } }
        }, @{
            Expression = { $_.Name }
        }
    }

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
            Update-MRU -ScriptName $selectedCmd.Name
            Write-Host "``$($selectedCmd.Name)``..." # Rassure le temps que neovide, par exemple, s'ouvre.
            if ($selectedCmd.Type -eq "Bash") {
                # Source the script and call invoke_command function
                $bashScript = "source '$($selectedCmd.ScriptPath)'; invoke_command '$project' '$spawnWt' '$projectPath' '$wtLocated'"
                wt -p "Git Bash" --title Bash --appendCommandLine $bashScript
            } elseif ($selectedCmd.Type -eq "PowerShell") {
                try {
                    # Source the script and call Invoke-Command function
                    . $selectedCmd.ScriptPath
                    Invoke-Command -project $project -spawnWt $spawnWt -projectPath $projectPath -wtLocated $wtLocated
                } catch {
                    Write-Host "Command failed: $($_.Exception.Message)" -ForegroundColor Red
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }
            }
        }
    }
}
