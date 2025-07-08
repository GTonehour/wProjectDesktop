function Get-ConfigPath {
    $installDir = "$env:LocalAppData\wProjectDesktop"
    $configPathFile = "$installDir\configPath.txt"
    $configPath = Get-Content $configPathFile -Raw | ForEach-Object { $_.Trim() }
    return $configPath
}

function Get-ProjectList {
$configDir = Get-ConfigPath
$configPath = "$configDir\projects.json"
$config = Get-Content $configPath | ConvertFrom-Json

    $projectList = @()
    foreach ($item in $config) {
        $expandedPath = Invoke-Expression "`"$($item.Path)`""
        if ($item.children -eq $true) {  # Fixed condition
            $subfolders = Get-ChildItem -Path $expandedPath -Directory
            foreach ($sub in $subfolders) {
                $projectList += [PSCustomObject]@{Name = $sub.Name; Path = $sub.FullName}
            }
        } else {
            $name = $item.Label
            if (-not $name) {
                $name = Split-Path $expandedPath -Leaf
            }
            if (-not (Test-Path $expandedPath)) {
                $name += ' (not found)'
            }
            $projectList += [PSCustomObject]@{Name = $name; Path = $expandedPath}
        }
    }
    return $projectList
}
