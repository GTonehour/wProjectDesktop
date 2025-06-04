DetectHiddenWindows True ; Quand la fenêtre était dans un autre bureau, on la cache plutôt que planter. Arrive quand la commande nous a emmené ailleurs avant de repasser dans le Hide-Term, typiquement après projectSwitcher ; oui quand on ouvrait un nouveau projet on y exécutait focusTerm, dans lequel on a mis hideTerm en préalable ; mais un mauvais timing pourrait arriver quand on ouvre un projet déjà ouvert, ou si une autre tâche venait à nous faire bouger.
SetTitleMatchMode 2
TERM := "PrimaryDevTerm ahk_class CASCADIA_HOSTING_WINDOW_CLASS"
