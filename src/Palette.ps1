function Hide-Term {
    & $env:ahk_wPD "$PSScriptRoot\hideTermStandalone.ahk"
}

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

function Get-ScriptsFromDirectory {
    param([string]$Path,
        [hashtable]$Collection # Passed by reference so the function can modify it.
        )
    
    # Write-Host "Load scripts from $Path"
    $scriptFiles = Get-ChildItem -Path $Path -File
    foreach ($file in $scriptFiles) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $type = "" # Initialize type variable
        
        # Use a switch for better readability
        switch ($file.Extension.ToLower()) {
            ".ps1" { $type = "PowerShell" }
            ".sh"  { $type = "Bash" }
        }
        
        # If the file type is supported, add/overwrite it in the hashtable
        if (-not [string]::IsNullOrEmpty($type)) {
            # This is the key change: it adds a new entry or overwrites an existing one.
            $Collection[$name] = [PSCustomObject]@{
                Name         = $name
                ScriptPath   = $file.FullName
                Type         = $type
                MRUTimestamp = Get-MRUTimestamp -ScriptName $name 
            }
        }
    }
}    

function Invoke-SelectedCommand {
    param(
        [string]$selectedCommand,
        [string]$project,
        [string]$projectPath,
        [hashtable]$commands,
        [string]$Terminal
    )
    
    $selectedCmd = $commands.Values | Where-Object {$_.Name -eq $selectedCommand}
    Update-MRU -ScriptName $selectedCmd.Name
    Write-Host "``$($selectedCmd.Name)``..." # Rassure le temps que neovide, par exemple, s'ouvre.
    
    if ($selectedCmd.Type -eq "Bash") {
		wt -p "Git Bash" -d "$projectPath" --appendCommandLine $selectedCmd.ScriptPath
		# Ce qui suit ne reconduisait pas les variables d'environnement
		# $wslpath = wsl wslpath -a $($selectedCmd.ScriptPath).Replace("\", "\\")
		# wt -p "Git Bash" -d "$projectPath" -- bash $wslpath
    } elseif ($selectedCmd.Type -eq "PowerShell") {
        try {
            try { # Tried to check if script encoding is understood by user's powershell without waiting for that long and ugly Get-Help to fail... but didn't succeed.
                $help = Get-Help $selectedCmd.ScriptPath -Full # NOTES prints only with the "Full" flag
            } catch {
                Write-Host "The version of your `"PowerShell`" fails to parse $($selectedCmd.ScriptPath). This can happen when it contains characters (emojis) unsupported by your PS encoding." -ForegroundColor Red
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            $metadata = @{}
            # Parse the .NOTES section into a hashtable
            $help.alertSet.alert.Text -split "`r`n|`r|`n" | ForEach-Object {
                if ($_ -match '(.+?)\s*=\s*(.+)') {
                    $metadata[$matches[1].Trim()] = $matches[2].Trim()
                }
            }

            # 2. Check the metadata to decide how to run the script
            # Spwan true by default, because the most common, at least for defaultPalette scripts.
            if ($metadata.Spawn -eq 'false') {
                # Run in the current console
                # The script will inherit the variables from this scope
                $result = . $selectedCmd.ScriptPath -project $project -projectPath $projectPath
                return $result
            } else {
                $title = if ($metadata.Title) { $metadata.Title } else { "$($selectedCmd.Name) - $project" }
                $scriptToRun = "& `"$($selectedCmd.ScriptPath)`" -projectPath `"$projectPath`" -project $project"
                $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptToRun))
                $powershellExecutable = if ($settings -and $settings.powershellExecutable) { $settings.powershellExecutable } else { "powershell" }
                $innerCommand = "$powershellExecutable -NoProfile -EncodedCommand $encodedCommand"
                
                # Check if Admin = true is specified in the metadata
                $runAsAdmin = ($metadata.Elevated -eq 'true')
                
                if ($Terminal -eq "wt") { # The instance spawned with `wt -- powershell` will get the environment variables of the main instance. (even though `wt` gets the updated ones)
                    if ($runAsAdmin) {
                        Start-Process wt -Verb RunAs -ArgumentList @(
                            "-d `"$projectPath`"",
                            "--title `"$Title`"",
                            "--",
                            $innerCommand
                        )
                    } else {
                        Start-Process wt -ArgumentList @(
                            "-d `"$projectPath`"",
                            "--title `"$Title`"",
                            "--",
                            $innerCommand
                        )
                    }
                } else {
                    if ($runAsAdmin) {
                        Start-Process cmd.exe -Verb RunAs -ArgumentList @(
                            "/c",
                            "start",
                            "alacritty",
                            "--working-directory",
                            "`"$projectPath`"",
                            "--title",
                            "`"$Title`"",
                            "-e",
                            $innerCommand
                        ) -WindowStyle Hidden
                    } else {
                        Start-Process cmd.exe -ArgumentList @( # If we close the wPD instance (typically by mistake), we don't want all the spawned alacritty instances to close too.
                            "/c",
                            "start",
                            "alacritty",
                            "--working-directory",
                            "`"$projectPath`"",
                            "--title",
                            "`"$Title`"",
                            "-e",
                            $innerCommand
                        ) -WindowStyle Hidden 
                    }
                }
            }
        } catch {
            Write-Host "Command failed: $($_.Exception.Message)" -ForegroundColor Red
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

$switchedKey = 'f12'

function Get-PaletteCommands {
   param (
        [string]$wPdDir
    )
    $configPalettePath = Join-Path (Get-ConfigPath) "Palette"
    $commands = @{}
    Get-ScriptsFromDirectory -Path (Join-Path $wPdDir "DefaultPalette") -Collection $commands
    Get-ScriptsFromDirectory -Path $configPalettePath -Collection $commands
    return $commands
}

$settings = Get-Settings
$Terminal = if ($settings -and $settings.terminal) { $settings.terminal } else { "wt" }

function Show-Palette {
    while($true){
        if(-Not $keepOpened){
            Hide-Term
        }
        $keepOpened=$false
        Clear-Host # Sinon on verra tous les "Executing" (et "Command failed") précédents le temps que la commande s'exécute. Pas juste avant le "executing" parce qu'on veut aussi effacer les "Not a project". Pas réussi à mock.
        $project = Get-CurrentDesktop | Get-DesktopName # 27mai25: "FromDesktop" failed with "Object reference not set to an instance of an object." 1.5.10\VirtualDesktop.ps1:1687 char:42. A relaunch of startupDocs.ps1 fixed it.
        $projectList = Get-ProjectList
        $projectObj = $projectList | Where-Object { $_.Name -eq $project }
        if ($projectObj) {
            $projectPath = $projectObj.Path
            Set-Location $projectPath -ErrorVariable notAProject -ErrorAction SilentlyContinue
            if ($notAProject) {
                $projectPath = $env:USERPROFILE
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

        # -w $project # Si on veut nommer une fenêtre dans le but d'y ouvrir d'autres onglets. (Pour le titre, voir --title)

        $commands = Get-PaletteCommands -wPdDir $wProjectDesktop
    
        # Sort commands: MRU first (most recent first), then alphabetically for untracked
        $cmds = $commands.Values | Sort-Object @{
            Expression = { if ($_.MRUTimestamp) { 0 } else { 1 } }
        }, @{
            Expression = { if ($_.MRUTimestamp) { -$_.MRUTimestamp.Ticks } else { 0 } }
        }, @{
            Expression = { $_.Name }
        }

        # 1. Pas trop avant le fzf sinon si on était sur A puis qu'on va sur B jusqu'au changement d'état et qu'on va sur C (pouvant être A) avant le fzf, "Esc" pourrait envoyé dans le vide et donc rester incohérent.
        # 2. Pas trop après sinon si on était sur A puis qu'on va jusqu'au fzf sur B et qu'on revient sur A avant que l'état soit sur B, l'état restera incohérent.
        # Dans les deux cas on peut rester dans un état incohérent. Certes le scénario le moins probable est le 2 (car suppose A->B->A plutôt que A->B->CdontA), MAIS on préfère avoir un state pour le tout premier après Startup.
        Set-Content -Path "$wProjectDesktop\State\currentProject.txt" -Value $project -NoNewline -Encoding Default

        $Name = $cmds | ForEach-Object {$_.Name} | fzf.exe --prompt "$projectToDisplay > " --cycle --expect=$switchedKey # Pas `--bind one:accept`. Sinon par exemple pour aller à "lazygit" je tapais "laz" qui ouvrait lazygit, puis "ygit"... qui l'ouvrait à nouveau.

        if ($Name.Count -eq 2) { # Aura toujours deux valeurs (0 si on a escaped), à cause de mon expect. Mais la première ne sera remplie (de switchedKey) que si j'ai appuyé cette dernière.
            if ($Name[0] -eq $switchedKey) {
                $keepOpened=$true
            } else {
                Invoke-SelectedCommand -selectedCommand $Name[1] -project $project -projectPath $projectPath -commands $commands -Terminal $Terminal
            }
        }
    }
}
