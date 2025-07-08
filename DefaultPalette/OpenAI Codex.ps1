function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    Invoke-Expression "$wtCommand --title `"OpenAI Codex $project`" wsl bash -i -c `"codex`""
}
