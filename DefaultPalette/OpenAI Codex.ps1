function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$spawnWt -p cmdLatte--title `"OpenAI Codex $project`" wsl bash -i -c `"codex`""
}
