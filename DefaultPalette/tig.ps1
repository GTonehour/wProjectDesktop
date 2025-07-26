function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $terminalCommand = & $NewTerminalCmd "tig" "tig $project"
    Invoke-Expression $terminalCommand
}
