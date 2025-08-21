BeforeAll {
    $wPdDir = "$PSScriptRoot\.."
    . $wPdDir\src\Palette.ps1
    # On veut pouvoir tester sans avoir installé (aussi pour pouvoir automatiser les tests sur des serveurs Linux). Donc on veut pouvoir mock Get-ConfigPath vers un dossier créé par Setup-DevDir. Mais Get-ConfigPath est appelé par Get-ProjectList, qui est hors du périmètre du mock. Donc on doit dot-sourcer avant, c'est à dire ici.
    . $wPdDir\src\ProjectUtils.ps1
    . $wPdDir\src\Show-Term.ps1
}

Describe 'Palette' {
    $terminals = @(
        @{ Terminal = "wt" }
        @{ Terminal = "alacritty" }
    )
    $nonceCommands = @(
        @{ Command = "spawning write with spaces" }
        @{ Command = "nospawn" }
        @{ Command = "elevated" }
        @{ Command = "nospawn elevated" }
    )
    $testCases = foreach ($terminal in $terminals) {
        foreach ($command in $nonceCommands) {
            @{
                Terminal = $terminal.Terminal
                Command = $command.Command
            }
        }
    }
    BeforeEach {
        # function fzf.exe { # Plante avec Mock, peut-être parce que pas un cmdlet.
        #     return 'simple_print.ps1'
        # }
        Mock Hide-Term { }
		Mock Get-ConfigPath { return Join-Path $wPdDir fixtures testsConfig }
		Mock cls { }
        $commands = Get-PaletteCommands -wPdDir $wPdDir # AFTER having mocked Get-ConfigPath, because we want testsConfig
        $testDump = Join-Path $wPdDir fixtures "path with spaces" # Not in $env:TEMP because the environment in elevated commands... is the admin's, while the file's existence will be checked in the $env:TEMP of the Pester runner's user.
        Set-Location $testDump # So that the "nospawn" commands create the file there too.
    }

    AfterEach {
        Get-ChildItem -Path $testDump -Filter "pester-*.txt" | Remove-Item -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path $env:Temp -Filter "pester-*.txt" | Remove-Item -Force -ErrorAction SilentlyContinue # For test-runner.ps1
    }    
    
    It 'executes simple script with <Terminal>' -ForEach $terminals {
        $result = Invoke-SelectedCommand -selectedCommand 'simple_print' -commands $commands -project "Test" -projectPath "." -Terminal $Terminal
        $result | Should -Be 'PALETTE_TEST_SUCCESS'
    }
    
    It '<Command> with <Terminal>' -ForEach $testCases {
        $nonce = $(New-Guid)
        Invoke-SelectedCommand -selectedCommand $Command -commands $commands -project $nonce -projectPath "$testDump" -Terminal $Terminal
        Start-Sleep -Seconds 6 # 3 insuffisant
        Test-Path (Join-Path $testDump "pester-$nonce.txt") | Should -Be $true
     }

    It 'spawns wt which runs <Command> with <Terminal>' -ForEach $testCases {
        $nonce = $(New-Guid)
        $tempRunnerScript = Join-Path $env:TEMP "pester-runner.ps1"

        # To "inherit" the Get-Config mocking in $tempRunnerScript
        $commandsJson = [System.Management.Automation.PSSerializer]::Serialize($commands)
#         $commands.GetEnumerator() | ForEach-Object {
#     Write-Host "$($_.Key): $($_.Value)"
# }
        $scriptContent = @"
# Here in addition to "Before", because this one will execute in our spawned terminal
. '$wPdDir\src\Palette.ps1'
. '$wPdDir\src\ProjectUtils.ps1'
`$commands = [System.Management.Automation.PSSerializer]::Deserialize('$commandsJson')
# Write-Host $Command
# Write-Host `$commands.Count
# `$commands.GetEnumerator() | ForEach-Object {
#     Write-Host "`$(`$_.Key): `$(`$_.Value)"
# }
Invoke-SelectedCommand -selectedCommand "$Command" -commands `$commands -project '$nonce' -projectPath "$testDump" -Terminal $Terminal
# Read-Host
"@
        # Create the temporary runner script
        $scriptContent | Out-File -FilePath $tempRunnerScript -Encoding UTF8
        
        # The command to execute our runner script in a new, non-focused wt process
        Start-WindowsTerminal -ScriptPath $tempRunnerScript -WithPositioning $false

        Start-Sleep -Seconds 10 # 7 wasn't enough on some devices.

        # Assert that the final output file was created by the nested process
        Test-Path (Join-Path "$testDump" "pester-$nonce.txt") | Should -Be $true
    }
}
