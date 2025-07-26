function Invoke-Command {
    param($project, $projectPath, $NewTerminalCmd)
    . $PSScriptRoot\..\src\projectSwitcher.ps1
}