function Get-ConfigPath {
    # We thought of writing the configPath at install time. But an environment variable may be a good idea too, because easily modifiable. Especially in DevMode.
    $ConfigEnvVar = [Environment]::GetEnvironmentVariable("wPD_Config_Path", "User")
    if ($ConfigEnvVar) {
        return $ConfigEnvVar
    }
    return Get-Content "$env:LocalAppData\wProjectDesktop\configPath.txt" -Raw | ForEach-Object { $_.Trim() }
}

function Get-Settings {
    $configDir = Get-ConfigPath
    $settingsPath = "$configDir\settings.json"
    
    if (Test-Path $settingsPath) {
        $settings = Get-Content $settingsPath | ConvertFrom-Json
        return $settings
    }
    
    return $null
}

function Get-ProjectList {
    $configDir = Get-ConfigPath
    $configPath = "$configDir\projects.json"
    $config = Get-Content $configPath | ConvertFrom-Json

    $projectList = @()
    foreach ($item in $config) {
        $expandedPath = Invoke-Expression "`"$($item.Path)`""
        $name = $item.Label
        if (-not $name) {
            $name = Split-Path $expandedPath -Leaf
        }
        if ($expandedPath){ # The path may be a environment variable, null in some environments.
            if ($item.children -eq $true) {  # Fixed condition
                $subfolders = Get-ChildItem -Path $expandedPath -Directory
                foreach ($sub in $subfolders) {
                    $projectList += [PSCustomObject]@{Name = $sub.Name; Path = $sub.FullName}
                }
            } else {
                if (-not (Test-Path $expandedPath)) {
                    $name += ' (not found)'
                }
                $projectList += [PSCustomObject]@{Name = $name; Path = $expandedPath}
            }
        } else {
            $projectList += [PSCustomObject]@{Name = "$name (not found)"}
        }
    }
    return $projectList
}
