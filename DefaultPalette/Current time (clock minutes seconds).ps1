function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    $clockScript = "$PSScriptRoot\Resources\clock-script.ps1"
    Invoke-Expression "$spawnWt -p cmdLatte --title `"Clock $project`" powershell -File `"$clockScript`""
}