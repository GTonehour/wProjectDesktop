function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    git add .; git commit -m "Quick push"; git push
}