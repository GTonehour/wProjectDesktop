function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$spawnWt --title `"OpenAI Codex $project`" wsl bash -i -c `"codex`""
}
