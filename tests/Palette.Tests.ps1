BeforeAll {
    . $PSScriptRoot\..\src\Palette.ps1
# On veut pouvoir tester sans avoir installé (aussi pour pouvoir automatiser les tests sur des serveurs Linux). Donc on veut pouvoir mock Get-ConfigPath vers un dossier créé par Setup-DevDir. Mais Get-ConfigPath est appelé par Get-ProjectList, qui est hors du périmètre du mock. Donc on doit dot-sourcer avant, c'est à dire ici.
. $PSScriptRoot\..\src\ProjectUtils.ps1
}

Describe 'Palette' {
    BeforeEach {
        function fzf.exe { return 1 } # Plante avec Mock, peut-être parce que pas un cmdlet.
        Mock Hide-Term { }
		Mock Get-ConfigPath { return Join-Path $PSScriptRoot .. DevModeConfig }
		Mock cls { }
    }
    It 'Palette doesn''t break' {
# Get-ConfigPath will need us to install before testing.
        Run-Palette -TestRun $true | Should -Be 1
    }
}
