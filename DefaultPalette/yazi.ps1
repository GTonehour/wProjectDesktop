function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    Invoke-Expression "$wtCommand --title `"yazi $project`" yazi ."
}