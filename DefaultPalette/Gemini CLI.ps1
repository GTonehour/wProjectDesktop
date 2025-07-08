function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    Invoke-Expression "$wtCommand --title `"Gemini $project`" powershell gemini"
}
