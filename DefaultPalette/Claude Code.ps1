function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$spawnWt --title `"Claude Code $project`" wsl bash -i -c `"claude`""
}
