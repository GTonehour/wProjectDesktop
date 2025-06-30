BeforeAll {
    . $PSScriptRoot\..\src\Palette.ps1
}

Describe 'Palette' {
    BeforeEach {
        function fzf.exe { return 1 }
        function Hide-Term { }
    }
    It 'Palette doesn''t break' {
        Run-Palette -TestRun $true | Should -Be 1
    }
}
