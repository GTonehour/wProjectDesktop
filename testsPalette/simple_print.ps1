<#
.NOTES
Spawn = false
#>
param(
    [string]$project,
    [string]$projectPath
)

Write-Host "📤" # The wt instance spawned by Start-Term.ps1 ran PaletteStandalone.ps1 with "powershell", which can be a different version than the one we currently use. This resulted in commands ran by wPD (like Get-Help) fail while working from another powershell version. For instance emojis, supported by v7 default encoding but not v5's. Keeping this emoji here tests for developers having their PATH's "powershell"'s encoding being UTF8...
return 'PALETTE_TEST_SUCCESS'
