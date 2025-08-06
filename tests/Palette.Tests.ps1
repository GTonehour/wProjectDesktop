BeforeAll {
    . $PSScriptRoot\..\src\Palette.ps1
    # On veut pouvoir tester sans avoir installé (aussi pour pouvoir automatiser les tests sur des serveurs Linux). Donc on veut pouvoir mock Get-ConfigPath vers un dossier créé par Setup-DevDir. Mais Get-ConfigPath est appelé par Get-ProjectList, qui est hors du périmètre du mock. Donc on doit dot-sourcer avant, c'est à dire ici.
    . $PSScriptRoot\..\src\ProjectUtils.ps1
}

Describe 'Palette' {
    BeforeEach {
        function fzf.exe { # Plante avec Mock, peut-être parce que pas un cmdlet.
            return 'simple_print.ps1'
        }
        Mock Hide-Term { }
		Mock Get-ConfigPath { return Join-Path $PSScriptRoot .. DevModeConfig }
		Mock cls { }
    }
    It 'executes command correctly' {
        $commands = Get-PaletteCommands -wPdDir (Join-Path $PSScriptRoot ..) -loadTestsPalette $true
        # Write-Host "Found $($commands.Count) commands."
        $result = Invoke-SelectedCommand -selectedCommand 'simple_print' -commands $commands
        $result | Should -Be 'PALETTE_TEST_SUCCESS'
    }
}
