wProjectDesktop
Windows per-project command palette

Work, personal stuff, side-husle, dotfiles, notes... you developed multitasking skills (Alt+Tab 👀). But each project started to have their own windows and tabs: editor, browser, terminal, browser, explorer, Windows apps... Let's face it: it's a pain.

wProjectDesktop is a light and open-source project that displays each project in its own virtual desktop, and provides a project-aware command palette.

[VIDEO]

# Definitions (ou "Concept"?)

Projects are the directories you [configured], for instance %USERPROFILE%\projects subfolders.

Call the command palette with the [hotkey], chose "Open project" and pick one of them. The command palette supports [fuzzy-finding].

wProjectDesktop opens a virtual desktop dedicated to that project, and:
1. directly opens sites and apps you [configured] for that project (emails, instant messages and Jira for work ; Whatsapp and emails for personal stuff ; music player...)
2. displays the command palette again for you to pick the next program run.

Commands are [configurable], they run located in your project directory. Examples: `code .` (VS Code), `explorer .` (Windows explorer), `wt` (Windows terminal), `lazygit`, `yazi`, git commands... all opened in your project location, no need to "cd" anywhere.

# Motivation

# Small dependency
# Usage




> What if I want a dedicated desktop for something with apps but no files, for instance a music player?

Just create an empty "music" directory, as if it was a project. It might sound like a hack, but wProjectDesktop tries to rely on existing OS features instead of introducing specific settings, to be as [thin] as possible.



# Configuration


Multiple benefits:
- Alt+Tab focuses Windows related to your current project



The command palette runs your favorite programs already located in 
to seemlessly switch projects, 


, you need to handle
Multitasking becomes a pain when each project has multiple windows : terminal, editor, explorer, browser tabs...
becomes tricky when 
is maneagable if each one lied in only one app. But each has many 

Tired of 

