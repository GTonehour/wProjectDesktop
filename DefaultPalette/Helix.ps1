function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $terminalCommand = & $NewTerminalCmd "powershell hx ." "Helix $project"
    Invoke-Expression $terminalCommand
}
