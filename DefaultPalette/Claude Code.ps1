function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    Invoke-Expression "$wtCommand --title `"Claude Code $project`" wsl bash -i -c `"claude`""
}