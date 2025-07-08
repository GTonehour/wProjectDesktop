function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    Invoke-Expression "$wtCommand --title `"lazygit $project`" lazygit"
}