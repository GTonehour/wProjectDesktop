# wProjectDesktop : Windows per-project desktop & command palette

Work, personal stuff, side-husle, dotfiles, notes... multitasking is fun and games until each project starts having multiple windows (editor, browser, explorer, terminal, Windows apps, AI agent), creating an Alt+Tabbing hell.

wProjectDesktop is a light and open-source solution that displays each project in its own (Windows Native) Virtual Desktop, and provides a project-aware command palette.

[VIDEO]

# Usage

Projects are the directories you [configured](#projects), for instance %USERPROFILE%\projects subfolders.

Call the command palette with the [hotkey](#hotkey), chose "Open project" and pick one of them with [fuzzy-finding](https://github.com/junegunn/fzf).

wProjectDesktop opens a virtual desktop dedicated to that project, and:
1. directly opens sites and apps you [configured](#apps) for that project (emails, instant messages and Jira for work ; Whatsapp and emails for personal stuff ; music player...)
2. displays the command palette for you to pick the next program run.

Commands are [configurable](#configuration), they run located in your project directory: no need to cd anywhere! Examples: `code .` (VS Code), `explorer .` (Windows explorer), `wt` (Windows terminal), `lazygit`, `yazi`, git commands...

# Alternative strategies
## One editor per project
Modern editors (VS Code, Cursor) tend to be all-included: git, explorer, terminal... If your editor is good for you, then you solved multitasking : by alt+tab between editors of your different projects.

That works, until your editor ends up:
- missing features, that you'll need other apps for.
- or bloated by that excess of functionality (VS Code typically uses ten times much RAM than Neovide, for instance); which makes you want to replace it by a lighter text editor + a terminal + a git GUI, and so on.
In both cases, you end up having multiple windows per project, all in the same desktop, which becomes a pain to navigate.

## WM's workspaces
Window managers (GlazeWM, Komorebi, workspacer...) often implement "workspaces". Their sort of a reimplementation of Windows' native Virtual Desktops.

They're generally not compatible in any way with Windows Virtual Desktop:
- Komorebi explicitely doesn't try to support compatibility with Windows VD (https://github.com/LGUG2Z/komorebi/issues/15#issuecomment-901605163)

This have advantages:
- The WM developers are free to add all the features they want, not limited by the [lack of a proper API for Windows Virtual Desktop](https://devblogs.microsoft.com/oldnewthing/20201123-00/?p=104476).

But also some drawbacks:
- Each WM implements its own thing
- Limited adoption means limited compatibility with other apps
- Lacks the nice integration the native VD has with Windows:
  - Alt+Tab being limited to the current desktop, according to the multitasking Windows settings. (I raised that issue to Komorebi, which likely won't implement that feature: https://github.com/LGUG2Z/komorebi/issues/505#issuecomment-2855404155)
  - The nice Tasks view (Win+Tab) UI, which allows to nicely move windows between desktops, show a window on all desktops, etc.

# Installation
## Executable
Not ready yet.
## git clone
- Install [AutoHotkey v2](www.autohotkey.com/about)
- ~~~ps1
  git clone ...
  Set-Location wProjectDesktop
  .\Install.ps1
  # Or with custom config path:
  .\Install.ps1 -customConfig "C:\MyCustomConfig"
  ~~~

# Features
- Alt+Tab focuses Windows related only to your current project.
- [Hotkey (F1 by default)](#hotkey) to call the command palette from everywhere.
- Opens a dedicated desktop for each project.

# Configuration
Configuration folder will be in `%LocalAppData%\wProjectDesktop\config` by default. You can replace it by a custom one using the `-customConfig` parameter during installation (e.g., `.\Install.ps1 -customConfig "C:\MyCustomConfig"`).

## Projects
project.json
## Commands
"Palette" folder
## Hotkey
Coming soon.
## Apps
Coming soon.

# Comparisons
## FlowLauncher
## rofi (Linux)

# Small footprint
- Can be installed and used without admin rights
- Uses natives Windows terminal, Virtual Desktops...

# FAQ
> What if I want a dedicated desktop for something with apps but no files, for instance a music player?

Just create an empty "music" directory, as if it was a project. It might sound like a hack, but wProjectDesktop tries to rely on existing OS features instead of introducing specific settings, to be as [thin] as possible.

# Development
## Prerequisites
## Install
- Install (AutoHotkey v2)[www.autohotkey.com/about]
- 
  ~~~ps1
  Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
  ~~~
## Run
TODO
~~~ps1
git clone ...
Set-Location wProjectDesktop
[Environment]::SetEnvironmentVariable("ahk_wPD", ..., "User") # Path to the (AutoHotkey v2)[www.autohotkey.com/about] executable (or run Install.ps1)
[Environment]::SetEnvironmentVariable("wPD_VirtualDesktop_exe", ..., "User") # Path to (VirtualDesktop.exe)[https://github.com/MScholtes/VirtualDesktop/releases/download/V1.20/VirtualDesktop11-24H2.exe].
~~~
or run once
~~~ps1
.\DevMode.ps1
~~~
Or if you want to test only the terminal without the initial Destkop initialization:
~~~ps1
.\src\Start-Term.ps1
~~~

# ... or schedule for startup.
~~~ps1
.\DevModeSchedule.ps1
~~~
