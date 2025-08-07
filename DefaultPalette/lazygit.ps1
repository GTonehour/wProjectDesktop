param($project, $projectPath, $NewTerminalCmd)
$terminalCommand = & $NewTerminalCmd "lazygit" "lazygit $project"
Invoke-Expression $terminalCommand
