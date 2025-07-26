function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $terminalCommand = & $NewTerminalCmd "yazi ." "yazi $project"
    Invoke-Expression $terminalCommand
}