# Adapt palette options to project
## Study
Adapting the command palette according to the desktop we're currently in seems like a legitimate use case, ne serait-ce que displaying the current project name.

Users can change desktop with wProjectDesktop, but also using Windows built-in commands (task view, Ctrl+Win+Left/Right...). If Microsoft provided an API to catch those events, we could spawn a hidden PowerShell terminal located in that new desktop, waiting for the user to call it.

As it is not the case we can evaluate the current desktop when the user calls the palette. Then we could:
1. run a PowerShell command in the existing terminal, to change its content. But AutoHotKey only provides key inputs to interact with the terminal, which seems clunky.
2. appendCommand in a new terminal, but that's the waiting time we expected to prevent the user from waiting.
3. only remaining solution: preparing one hidden terminal per project. On call of the palette, AHK would evaluate the current desktop and call the right command (or call the only terminal in the current desktop).

## Options
### 1. Don't adapt the palette to the project
### 2. One terminal per project... +1
Whenever a project is opened (legitimatealy or with ctrl+maj+D), the user shouldn't wait for the creation of a new terminal; so we would manage an additional one that would serve only as the first command run after creation?
### 3. Make AHK reload the script when desktop was changed outside
wt sets its desktop in a state before each fzf
On hotkey, AHK checks if current desktop matches state
If not, inputs <Esc> (which triggers new desktop evaluation by ps1) and Show.

State stored in a text file. Not the title because would both suppose that terminal can change its own title, AND that ahk could target it even with a bad title.

## Comparisons
### 2/1
+ afficher le nom du projet courant dans le terminal
+ changer les commandes disponibles. On pourrait imaginer une commande "project specific commands" mais elle demanderait un clic.
- multiplies the RAM usage with number of projects.
- complicated (especially that "+1")? 🦑
* complique le code ; mais si on ne fait pas ça, exige que les $Cmds.Cmd soient des fonctions plutôt que des strings, puisqu'on ne calculera le projet qu'après fzf.

### 💖 3/2
* - commanding terminal with input keys is clunky... buyt it's just one Esc
- flickers when that happens, whereas having prepared a dedicated terminal was immediate
+ saves RAM
+ seems simpler 🦑
