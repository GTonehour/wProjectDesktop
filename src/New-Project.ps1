$ProjectConfigs = @{
    'work' = @{
        sites = @(
            'https://mail.telamon.eu/',
            'https://mattermost.telamon.eu/'
        )
        processes = @(
            'ms-teams'
        )
    }
    'music' = @{
        sites = @(
            'https://music.youtube.com'
        )
        processes = @()
    }
    'docs' = @{
        sites = @()
        processes = @(
            'Thunderbird'
			,"C:\Program Files\WindowsApps\5319275A.WhatsAppDesktop_2.2518.3.0_x64__cv1g1gvanyjgm\WhatsApp.exe" # Seriously winget? J'imagine que sera différent la prochaine fois... chercher, alors.
        )
    }
}
function New-Project {
	param (
		$projectName
	)

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
    }
}
