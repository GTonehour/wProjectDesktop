param($project, $projectPath, $NewTerminalCmd)
Invoke-Expression "wt -d $projectPath -p Ubuntu --title `"WSL $project`""
