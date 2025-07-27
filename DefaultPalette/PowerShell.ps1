function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $terminalCmd = New-TerminalCmd -Title "PowerShell $project"
    Invoke-Expression $terminalCmd
}
