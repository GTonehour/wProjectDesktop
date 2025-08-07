BeforeAll {
    . $PSScriptRoot\..\src\Palette.ps1
    # On veut pouvoir tester sans avoir installé (aussi pour pouvoir automatiser les tests sur des serveurs Linux). Donc on veut pouvoir mock Get-ConfigPath vers un dossier créé par Setup-DevDir. Mais Get-ConfigPath est appelé par Get-ProjectList, qui est hors du périmètre du mock. Donc on doit dot-sourcer avant, c'est à dire ici.
    . $PSScriptRoot\..\src\ProjectUtils.ps1
}

Describe 'Palette' {
    $terminals = @(
        @{ Terminal = "wt" }
        @{ Terminal = "alacritty" }
    )
    BeforeEach {
        function fzf.exe { # Plante avec Mock, peut-être parce que pas un cmdlet.
            return 'simple_print.ps1'
        }
        Mock Hide-Term { }
		Mock Get-ConfigPath { return Join-Path $PSScriptRoot .. DevModeConfig }
		Mock cls { }
    }

    AfterEach {
        # Clean up test files after each test
        Get-ChildItem -Path $env:TEMP -Filter "pester-*.txt" | Remove-Item -Force -ErrorAction SilentlyContinue
    }    
    
    It 'executes simple script with <Terminal>)' -ForEach $terminals {
        $commands = Get-PaletteCommands -wPdDir (Join-Path $PSScriptRoot ..) -loadTestsPalette $true
        $result = Invoke-SelectedCommand -selectedCommand 'simple_print' -commands $commands -project "Test" -projectPath "." -Terminal alacritty
        $result | Should -Be 'PALETTE_TEST_SUCCESS'
    }
    
    It 'script containing space in name spawns and executes' -ForEach $terminals {
        $nonce = $(New-Guid)
        
        $commands = Get-PaletteCommands -wPdDir (Join-Path $PSScriptRoot ..) -loadTestsPalette $true
        Invoke-SelectedCommand -selectedCommand 'spawning write with spaces' -commands $commands -project $nonce -projectPath "." -Terminal alacritty
        
        Start-Sleep -Seconds 3
        
        Test-Path (Join-Path $env:Temp "pester-$nonce.txt") | Should -Be $true
     }
}
