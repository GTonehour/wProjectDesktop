function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$spawnWt -p cmdLatte --title `"yazi $project`" yazi ."
}