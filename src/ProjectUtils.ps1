function Get-ProjectList {
# Read config path from configPath.txt
$installDir = "$env:LocalAppData\wProjectDesktop"
$configPathFile = "$installDir\configPath.txt"
$configDir = Get-Content $configPathFile -Raw | ForEach-Object { $_.Trim() }
$configPath = "$configDir\projects.json"

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
