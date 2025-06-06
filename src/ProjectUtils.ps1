function Get-ProjectList {
$configPath = "$env:LocalAppData\wProjectDesktop\config\projects.json"

if (-not (Test-Path $configPath)) {
   Write-Host "Config file not found at: $configPath" -ForegroundColor Red
   Write-Host "Please create the config file first." -ForegroundColor Yellow
   exit 1
}

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
                $name = (Get-Item $expandedPath).Name
            }
            $projectList += [PSCustomObject]@{Name = $name; Path = $expandedPath}
        }
    }
    return $projectList
}
