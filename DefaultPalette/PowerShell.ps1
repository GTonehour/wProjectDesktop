param($project, $projectPath)

. "$PSScriptRoot\..\src\ProjectUtils.ps1"
$settings = Get-Settings
$powershellExecutable = if ($settings -and $settings.powershellExecutable) { $settings.powershellExecutable } else { "powershell" }

& $powershellExecutable
