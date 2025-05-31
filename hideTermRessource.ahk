#Requires AutoHotkey v2.0
#SingleInstance force
HideTerm(){

	DetectHiddenWindows True ; Quand la fenêtre était dans un autre bureau, on la cache plutôt que planter. Arrive quand la commande nous a emmené ailleurs avant de repasser dans le Hide-Term, typiquement après projectSwitcher ; oui quand on ouvrait un nouveau projet on y exécutait focusTerm, dans lequel on a mis hideTerm en préalable ; mais un mauvais timing pourrait arriver quand on ouvre un projet déjà ouvert, ou si une autre tâche venait à nous faire bouger.

    SetTitleMatchMode 2
    local windowToHide := 'PrimaryDevTerm ahk_class CASCADIA_HOSTING_WINDOW_CLASS'
	if WinExist(windowToHide){
	    WinHide windowToHide
	} else { ; If the user alt+F4d it for some reason
		RunWait 'powershell.exe -ExecutionPolicy Bypass -File ' . EnvGet("LocalAppData") . '\wProjectDesktop\Start-Term.ps1'
	}
}
