function Get-ConfigPath {
    # We thought of writing the configPath at install time. But an environment variable may be a good idea too, because easily modifiable. Especially in DevMode.
    $ConfigEnvVar = [Environment]::GetEnvironmentVariable("wPD_Config_Path", "User")
    if ($ConfigEnvVar) {
        return $ConfigEnvVar
    }
    return Get-Content "$env:LocalAppData\wProjectDesktop\configPath.txt" -Raw | ForEach-Object { $_.Trim() }
}

function Get-Json {
    param([string] $JsonPath)
    try {
        return Get-Content $JsonPath | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Write-Host "$JsonPath isn't valid JSON" -ForegroundColor Red
        Read-Host
        return
    }
}
function Get-Settings {
    $configDir = Get-ConfigPath
    $settingsPath = "$configDir\settings.json"
    
    if (Test-Path $settingsPath) {
        return Get-Json $settingsPath
    }
    
    return $null
}

function Get-ProjectList {
    $configDir = Get-ConfigPath
    $configPath = "$configDir\projects.json"

    if (-not (Test-Path $configPath)) {
        Write-Host "$configPath not found." -ForegroundColor Red
        Read-Host
        return
    }

    $config = Get-Json $configPath

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
                Clear-Host
                # Some paths are long to check, for instance "\\\\192.168.1.253@8080\\DavWWWRoot\\mnt\\...". Only the user will know if that's worth it, so let's let them decide.
                Write-Host "Checking if '$expandedPath' exists..."
                if (-not (Test-Path $expandedPath)) {
                    $name += ' (not found)'
                }
                $projectList += [PSCustomObject]@{Name = $name; Path = $expandedPath}
            }
        } else {
            $projectList += [PSCustomObject]@{Name = "$name (not found)"}
        }
    }

    $projectList | Group-Object Name | ForEach-Object {
        if ($_.Count -gt 1) {
            throw "projects.json contains two projects named $($_.Name)."
        }
    }

    return $projectList
}
