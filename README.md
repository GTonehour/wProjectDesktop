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

# Motivation

# Small dependency
# Usage




> What if I want a dedicated desktop for something with apps but no files, for instance a music player?

Just create an empty "music" directory, as if it was a project. It might sound like a hack, but wProjectDesktop tries to rely on existing OS features instead of introducing specific settings, to be as [thin] as possible.



# Discussions
## Adapt palette options to project
### Study
Adapting the command palette according to the desktop we're currently in seems like a legitimate use case, ne serait-ce que displaying the current project name.

Users can change desktop with wProjectDesktop, but also using Windows built-in commands (task view, Ctrl+Win+Left/Right...). If Microsoft provided an API to catch those events, we could spawn a hidden PowerShell terminal located in that new desktop, waiting for the user to call it.

As it is not the case we can evaluate the current desktop when the user calls the palette. Then we could:
1. run a PowerShell command in the existing terminal, to change its content. But AutoHotKey only provides key inputs to interact with the terminal, which seems clunky.
2. appendCommand in a new terminal, but that's the waiting time we expected to prevent the user from waiting.
3. only remaining solution: preparing one hidden terminal per project. On call of the palette, AHK would evaluate the current desktop and call the right command (or call the only terminal in the current desktop).

### Advantages
+ afficher le nom du projet courant dans le terminal
+ changer les commandes disponibles. On pourrait imaginer une commande "project specific commands" mais elle demanderait un clic.
- multiplies the RAM usage with number of projects.
* complique le code ; mais si on ne fait pas ça, exige que les $Cmds.Cmd soient des fonctions plutôt que des strings, puisqu'on ne calculera le projet qu'après fzf.






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

