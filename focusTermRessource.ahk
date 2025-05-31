#Requires AutoHotkey v2.0
#SingleInstance force
#Include hideTermRessource.ahk

FocusTerm(){
	TERM := "PrimaryDevTerm ahk_class CASCADIA_HOSTING_WINDOW_CLASS"
	SetTitleMatchMode 2

	; Ce terminal qu'on demande à afficher est peut-être ouvert dans un autre VD. Puisqu'on est ici suite :
	; - soit à F1 : or on a peut-être laissé le terminal ouvert ailleurs sans y finir.
	; - soit dans la foulée d'un Switch vers un New-Desktop: et on a vu que Windows/AHK réalisait souvent qu'on avait changé de bureau entre le winShow (encore dans l'ancien bureau) et le activateShow (dans le nouveau bureau, alors que le terminal est Show ailleurs) ce qui plantait (ou, si DetectHiddenWindows, l'activait, nous ramenant dans l'ancien bureau).
	; Avant tout affichage on masque donc, puisque ce n'est que cachée que les fenêtres semblent accepter de voyager. En conséquence on n'a plus besoin d'anticiper un Hide-Term avant de Switch-Desktop, ce qui simplifie projectSwitcher.ps1.
	DetectHiddenWindows True ; Déjà ce mode dans hideTermRessource, mais on on a besoin pour WinShow
	hideTerm()

	WinShow TERM
	WinActivate TERM
}
