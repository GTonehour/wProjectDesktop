function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$wtLocated -p cmdLatte -p Ubuntu --title `"WSL $project`""
}
