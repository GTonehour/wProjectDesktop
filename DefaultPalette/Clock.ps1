function Invoke-Command {
    param($project, $projectPath, $wtCommand)
    $clockScript = "$PSScriptRoot\Resources\clock-script.ps1"
    Invoke-Expression "$wtCommand --title `"Clock $project`" powershell -File `"$clockScript`""
}