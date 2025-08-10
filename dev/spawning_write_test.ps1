param(
    $nonce
)

$commands = Get-PaletteCommands -wPdDir (Join-Path $PSScriptRoot ..) -loadTestsPalette $true
Invoke-SelectedCommand -selectedCommand 'spawning write with spaces' -commands $commands -project $nonce -projectPath "." -Terminal alacritty

Start-Sleep -Seconds 3

Test-Path (Join-Path $env:Temp "pester-$nonce.txt") | Should -Be $true

