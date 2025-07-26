function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $terminalCommand = & $NewTerminalCmd "wsl bash -i -c `"claude`"" "Claude Code $project"
    Invoke-Expression $terminalCommand
}