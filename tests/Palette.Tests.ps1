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

    It 'doesnt get spaces mangled through the parsing of wt plus <Terminal>' -ForEach $terminals {
        $nonce = $(New-Guid)
        $tempRunnerScript = Join-Path $env:TEMP "pester-runner.ps1"
        # Resolve the absolute path to the project root for the external script
        $projectRootPath = Join-Path $PSScriptRoot ..

        # This is the content of the script that 'wt' will execute.
        # It needs absolute paths because its execution location is different.
        # Note the backticks (`) before `$commands` and `$true` to ensure they are
        # treated as literal text in the script file, not expanded immediately.
        $scriptContent = @"
. '$projectRootPath\src\Palette.ps1'
. '$projectRootPath\src\ProjectUtils.ps1'

`$commands = Get-PaletteCommands -wPdDir '$projectRootPath' -loadTestsPalette `$true
Invoke-SelectedCommand -selectedCommand 'spawning write with spaces' -commands `$commands -project '$nonce' -projectPath "." -Terminal $Terminal
"@
        # Create the temporary runner script
        $scriptContent | Out-File -FilePath $tempRunnerScript -Encoding UTF8
        
        # The command to execute our runner script in a new, non-focused wt process
        $wtCommand = "wt powershell -File $tempRunnerScript"
        Invoke-Expression $wtCommand

        Start-Sleep -Seconds 3

        # Assert that the final output file was created by the nested process
        Test-Path (Join-Path $env:Temp "pester-$nonce.txt") | Should -Be $true
    }
}
