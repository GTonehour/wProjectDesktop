function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    $clockScript = "$PSScriptRoot\Resources\clock-script.ps1"
    $terminalCommand = & $NewTerminalCmd "powershell -File `"$clockScript`"" "Clock $project"
    Invoke-Expression $terminalCommand
}