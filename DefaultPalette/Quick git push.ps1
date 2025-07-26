function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    git add .; git commit -m "Quick push"; git push
}