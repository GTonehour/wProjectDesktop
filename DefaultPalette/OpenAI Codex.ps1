function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $terminalCommand = & $NewTerminalCmd "wsl bash -i -c `"codex`"" "OpenAI Codex $project"
    Invoke-Expression $terminalCommand
}
