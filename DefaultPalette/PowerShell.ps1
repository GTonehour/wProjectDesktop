function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    Invoke-Expression "wt -d $projectPath --title `"PowerShell $project`""
}
