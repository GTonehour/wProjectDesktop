BeforeAll {
    . $PSScriptRoot\..\install_res\InstallFunction.ps1
}

Describe 'Install' {
    It 'Install doesn''t break' {

        Install-WPD -DryRun $true | Should -Be 1
    }
}
