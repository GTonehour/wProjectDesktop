function Show-Term {
	& $env:ahk_wPD "$PSScriptRoot\focusTermStandalone.ahk"
}

function Start-WindowsTerminal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [string]$WorkingDirectory = $null,
        [bool]$WithPositioning = $true,
        [string]$Title = "wProjectDesktop_37"
    )
    
    . $PSScriptRoot\ProjectUtils.ps1
    $settings = Get-Settings
    $powershellExecutable = if ($settings -and $settings.powershellExecutable) { $settings.powershellExecutable } else { "powershell" }
    
    if ($WithPositioning) {
        $screen = Get-CimInstance -ClassName Win32_VideoController
        $screenWidth = $screen.CurrentHorizontalResolution
        $screenHeight = $screen.CurrentVerticalResolution
        $charWidth = 8
        $charHeight = 18
        $cols = 50
        $rows = 20
        $windowWidth = $cols * $charWidth
        $windowHeight = $rows * $charHeight
        $x = [math]::Round(($screenWidth - $windowWidth) / 2)
        $y = [math]::Round(($screenHeight - $windowHeight) / 2)
        
        $wtArgs = @("--focus", "--pos", "$x,$y", "--size", "$cols,$rows", "--title", $Title)
        if ($WorkingDirectory) {
            $wtArgs += @("-d", $WorkingDirectory)
        }
        $wtArgs += @($powershellExecutable, "-File", $ScriptPath)
    } else {
        $wtArgs = @($powershellExecutable, "-File", $ScriptPath)
    }

    & wt @wtArgs
}

