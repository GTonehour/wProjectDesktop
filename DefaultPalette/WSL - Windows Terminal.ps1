<#
.NOTES
Spawn = false
#>
param($project, $projectPath)
Invoke-Expression "wt -d $projectPath -p Ubuntu --title `"WSL $project`""
