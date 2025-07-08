function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    Invoke-Expression "$wtCommand -p Ubuntu --title `"WSL $project`""
}
