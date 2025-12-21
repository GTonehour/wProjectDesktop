$ProjectConfigs = @{
    't_md' = @{
        sites = @(
            'https://mail.telamon.eu/',
            'https://barttelamon.atlassian.net/jira/software/c/projects/BK/boards/10',
            'https://mattermost.telamon.eu/'
        )
        processes = @(
            'ms-teams'
        )
    }
    'music' = @{
        # sites = @(
        #     'https://music.youtube.com'
        # )
        commands = @(
			# J'avais tendance à ouvrir d'autres onglets dans ce Chrome "music"...
			"& `"C:\Program Files\Google\Chrome\Application\chrome_proxy.exe`"  --profile-directory=Default --app-id=cinhimbnkkaeohfgghhklpknlkffjgod"
		)
    }
    'docs' = @{
        sites = @()
        processes = @(
            'Thunderbird'
        )
		commands = @(
			# 11dec25 I comment because not working in some devices
			# Pas dans processes car winget mets dans un chemin qui change à chaque montée de version, par exemple "C:\Program Files\WindowsApps\5319275A.WhatsAppDesktop_2.2518.3.0_x64__cv1g1gvanyjgm\WhatsApp.exe". A la main depuis le site c'est encore pire, même admin n'a pas accès au dossier. Et WhatsApp ne support plus scoop. On pourrait Get-ChildItem dans C:\Program Files\WindowsApps, mais nécessite admin... Et Whatsapp n'est dans les Start Menu\Programs de AppData ni de C:\ProgramData.
			# "& `"$env:projects\wProjectDesktop\src\RunWingetApp_WhatsApp.ps1`""
		)
    }
}
function New-Project {
	param (
		$projectName
	)

    Clear-Host # To hide "Checking if {last path in projects.json} exists" before "Trying to start WhatsApp..."
    if ($ProjectConfigs.ContainsKey($projectName)) {
        $config = $ProjectConfigs[$projectName]
        
        foreach ($site in $config.sites) {
            Start-Process chrome -ArgumentList "--window-name=$projectName", $site # On donne un nom à la fenêtre car quand on fait clic-droit sur l'onglet d'une autre fenêtre (peut-être dans un autre bureau), "déplacer vers une nouvelle fenêtre" liste ce window-name
        }
        foreach ($process in $config.processes) {
            try {
                Start-Process $process
            }
            catch {
                Write-Host "Can't open $process in $projectName" -ForegroundColor Red

            }
        }
        foreach ($command in $config.commands) {
            # Directly invoke command as a string to allow arguments
            Invoke-Expression $command
        }
    }
}
