function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    git add .; git commit -m "Quick push"; git push
}