function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $terminalCommand = & $NewTerminalCmd "powershell gemini" "Gemini $project"
    Invoke-Expression $terminalCommand
}
