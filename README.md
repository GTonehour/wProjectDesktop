wProjectDesktop
Windows per-project desktop & command palette

Work, personal stuff, side-husle, dotfiles, notes... multitasking is fun and games until each project starts having multiple windows (editor, browser, explorer, terminal, Windows apps), creating an Alt+Tabbing hell.

wProjectDesktop is a light and open-source solution that displays each project in its own (Windows Native) Virtual Desktop, and provides a project-aware command palette.

[VIDEO]

# Definitions (ou "Concept"?)

Projects are the directories you [configured], for instance %USERPROFILE%\projects subfolders.

Call the command palette with the [hotkey], chose "Open project" and pick one of them with [fuzzy-finding].

wProjectDesktop opens a virtual desktop dedicated to that project, and:
1. directly opens sites and apps you [configured] for that project (emails, instant messages and Jira for work ; Whatsapp and emails for personal stuff ; music player...)
2. displays the command palette for you to pick the next program run.

Commands are [configurable], they run located in your project directory: no need to cd anywhere! Examples: `code .` (VS Code), `explorer .` (Windows explorer), `wt` (Windows terminal), `lazygit`, `yazi`, git commands...

# Features
- Alt+Tab focuses Windows related to your current project

# Motivation

# Small dependency
# Usage

# Install
## Executable
## Clone
- Install (AutoHotkey v2)[www.autohotkey.com/about]
- ~~~ps1
  git clone ...
  Set-Location wProjectDesktop
  .\Install.ps1
  # Or with custom config path:
  .\Install.ps1 -customConfig "C:\MyCustomConfig"
  ~~~

# Configuration
Configuration will be in `%LocalAppData%\wProjectDesktop\config` by default. You can specify a custom config path using the `-customConfig` parameter during installation (e.g., `.\Install.ps1 -customConfig "C:\MyCustomConfig"`).

# FAQ
> What if I want a dedicated desktop for something with apps but no files, for instance a music player?

Just create an empty "music" directory, as if it was a project. It might sound like a hack, but wProjectDesktop tries to rely on existing OS features instead of introducing specific settings, to be as [thin] as possible.

# Development
## Install
~~~ps1
Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
~~~
## Dev Mode
- Install (AutoHotkey v2)[www.autohotkey.com/about]
~~~ps1
git clone ...
Set-Location wProjectDesktop
[Environment]::SetEnvironmentVariable("ahk_wPD", ..., "User") # Path to the (AutoHotkey v2)[www.autohotkey.com/about] executable (or run Install.ps1)
[Environment]::SetEnvironmentVariable("wPD_VirtualDesktop_exe", ..., "User") # Path to (VirtualDesktop.exe)[https://github.com/MScholtes/VirtualDesktop/releases/download/V1.20/VirtualDesktop11-24H2.exe].

# Run once
~~~ps1
.\DevMode.ps1
~~~
Or if you want to test the terminal without the initial Destkop initialization:
~~~ps1
.\src\Start-Term.ps1
~~~

# ... or schedule for startup.
.\DevModeSchedule.ps1
~~~

