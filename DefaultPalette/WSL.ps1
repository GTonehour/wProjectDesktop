function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$wtLocated -p Ubuntu --title WSL"
}