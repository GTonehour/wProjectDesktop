function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $terminalCommand = & $NewTerminalCmd "nvim ." "nvim $project"
    Invoke-Expression $terminalCommand
}