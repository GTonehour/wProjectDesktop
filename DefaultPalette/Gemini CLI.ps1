function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$spawnWt --title `"Gemini $project`" powershell gemini"
}
