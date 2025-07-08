function Hide-Term {
    & $env:ahk_wPD "$PSScriptRoot\hideTermStandalone.ahk"
}
function Run-Palette {
    param([bool]$TestRun = $false)
    # Ce qui se passe ici doit faire l'object d'un test, car c'est ce que Start-Term lancera.
$wProjectDesktop=(Join-Path $PSScriptRoot ..)

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
    cls # Sinon on verra tous les "Executing" (et "Command failed") précédents le temps que la commande s'exécute. Pas juste avant le "executing" parce qu'on veut aussi effacer les "Not a project". Pas réussi à mock.
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
    $spawnWt = "$wtLocated"
    # -w $project # Si on veut nommer une fenêtre dans le but d'y ouvrir d'autres onglets. (Pour le titre, voir --title)

    # Load commands from DefaultPalette and config/Palette folders
    $defaultPalettePath = Join-Path $wProjectDesktop "DefaultPalette"
    $configPath = Get-ConfigPath
    $configPalettePath = Join-Path $configPath "Palette"
$cmds = [System.Collections.ArrayList]@()
    
    # Function to load scripts from a directory
    function Load-ScriptsFromDirectory {
        param([string]$Path, [string]$Source)
        
        $scriptFiles = Get-ChildItem -Path $Path -File
        
        foreach ($file in $scriptFiles) {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $extension = $file.Extension.ToLower()
            
            if ($extension -eq ".ps1") {
                $mruTimestamp = Get-MRUTimestamp -ScriptName $name
$null = $cmds.Add([PSCustomObject]@{
                    Name = $name
                    ScriptPath = $file.FullName
                    Type = "PowerShell"
                    MRUTimestamp = $mruTimestamp
                    Source = $Source
                })
            } elseif ($extension -eq ".sh") {
                $mruTimestamp = Get-MRUTimestamp -ScriptName $name
$null = $cmds.Add([PSCustomObject]@{
                    Name = $name
                    ScriptPath = $file.FullName
                    Type = "Bash"
                    MRUTimestamp = $mruTimestamp
                    Source = $Source
                })
            }
        }
    }
    
    # Load from DefaultPalette (starter pack)
    Load-ScriptsFromDirectory -Path $defaultPalettePath -Source "Default"
    
    # Load from config/Palette (user scripts) - these will override defaults with same name
    Load-ScriptsFromDirectory -Path $configPalettePath -Source "Config"
    
    # Remove default scripts if custom ones with same name exist
    $customNames = ($cmds | Where-Object { $_.Source -eq "Config" }).Name
    $cmds = $cmds | Where-Object { $_.Source -eq "Config" -or $_.Name -notin $customNames }
    
    # Sort commands: MRU first (most recent first), then alphabetically for untracked
    $cmds = $cmds | Sort-Object @{
        Expression = { if ($_.MRUTimestamp) { 0 } else { 1 } }
    }, @{
        Expression = { if ($_.MRUTimestamp) { -$_.MRUTimestamp.Ticks } else { 0 } }
    }, @{
        Expression = { $_.Name }
    }

    $switchedKey = 'f12'

    # 1. Pas trop avant le fzf sinon si on était sur A puis qu'on va sur B jusqu'au changement d'état et qu'on va sur C (pouvant être A) avant le fzf, "Esc" pourrait envoyé dans le vide et donc rester incohérent.
    # 2. Pas trop après sinon si on était sur A puis qu'on va jusqu'au fzf sur B et qu'on revient sur A avant que l'état soit sur B, l'état restera incohérent.
    # Dans les deux cas on peut rester dans un état incohérent. Certes le scénario le moins probable est le 2 (car suppose A->B->A plutôt que A->B->CdontA), MAIS on préfère avoir un state pour le tout premier après Startup.
    Set-Content -Path $wProjectDesktop\State\CurrentProject.txt -Value $project -NoNewline

    $Name = $cmds | ForEach-Object {$_.Name} | fzf.exe --prompt "$projectToDisplay > " --cycle --expect=$switchedKey # Pas `--bind one:accept`. Sinon par exemple pour aller à "lazygit" je tapais "laz" qui ouvrait lazygit, puis "ygit"... qui l'ouvrait à nouveau.

    if ($Name.Count -eq 2) { # Aura toujours deux valeurs (0 si on a escaped), à cause de mon expect. Mais la première ne sera remplie (de switchedKey) que si j'ai appuyé cette dernière.
        if ($Name[0] -eq $switchedKey) {
            $keepOpened=$true
        } else {
            $selectedCmd = $cmds | Where-Object {$_.Name -eq $Name[1]}
            Update-MRU -ScriptName $selectedCmd.Name
            Write-Host "``$($selectedCmd.Name)``..." # Rassure le temps que neovide, par exemple, s'ouvre.
            if ($selectedCmd.Type -eq "Bash") {
				wt -p "Git Bash" -d "$projectPath" --appendCommandLine $selectedCmd.ScriptPath
				# Ce qui suit ne reconduisait pas les variables d'environnement
				# $wslpath = wsl wslpath -a $($selectedCmd.ScriptPath).Replace("\", "\\")
				# wt -p "Git Bash" -d "$projectPath" -- bash $wslpath
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
    
    if ($TestRun) {
        break
    }
}
    if ($TestRun) {
        return $Name
    }
}
