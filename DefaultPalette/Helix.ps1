function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    Invoke-Expression "$wtCommand --title `"Helix $project`" powershell hx ."
}
