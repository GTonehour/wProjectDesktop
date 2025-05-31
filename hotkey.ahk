#Include focusTermRessource.ahk
#Include hideTermRessource.ahk

; RunPowershell(psScript ; Dont suffixe .ps1 pour mieux détecter le fichier à la relecture.
; )
; {
; 	FocusTerm()
; 	; If the window is not found, the script does nothing further,
; 		; aligning with the "don't bother catching errors" preference.
;
;     Send('{LWin up}')  ; Force-release Win key first. Sinon les touches suivants déclenchaient d'autres hotkeys.
; 	Send('{Escape}') ; Par exemple après avoir ouvert un nouveau projet avec <C-o>, le <C-t> se déclenche, ouvrant un fzf. Mais supposons qu'au lieu de lancer une commande, je veuille à nouveau faire <C-o> pour ouvrir un autre projet : je dois d'abord sortir du fzf précédent. Je ne risque pas d'escape autre chose, car on a déjà Focus le Term.
;     Send('cls{Enter}') ; Inutile d'afficher les commandes précédentes. Si ?
;     Send('{Text}& "$env:USERPROFILE\projects\dotfiles\' . psScript . '"')  ; Text mode for special characters
;     Send('{Enter}')  ; Proper Enter key press
;
;
; 			; releaseWin := '{LWin up}{Text}' ; Sinon, ma Win key reste active pendant le Send, qui déclenche d'autres hotkeys...
; 			; Send(releaseWin . '& "F:\Archive_md\' . psScript . '"{Enter}')
; }

; #o::RunPowershell("projectSwitcher.ps1") ; Finalement j'en fais une simple commande de inProject...ps1
; #t::RunPowershell("inProjectVirtualDesktopOpenTerminal.ps1")

; Directly, because initiating powershell was half a second...
exePath      := EnvGet('projects') . "\bin\VirtualDesktop.exe"
if !FileExist(exePath)
{
    MsgBox("Error: VirtualDesktop executable not found at:`n" . exePath, "Script Error", 16)
    ExitApp
}

#m:: SwitchToDesktop("music")
#a:: SwitchToDesktop("docs") ; #d est déjà pris.

SwitchToDesktop(desktopName)
{
    global exePath
    Run(exePath . ' /Switch:"' . desktopName . '"', , "Hide")
}

RingFile := "2"
; RingFile := "ding"
Ring := FileRead("Sounds\" . RingFile . ".wav", "RAW")
PlaySound(Sound) {
		DllCall("winmm.dll\PlaySound", "Ptr", Sound, "UInt", 0, "UInt", 0x5)
	}

F1::{
	; SoundPlay A_WinDir "\Media\ding.wav" ; , WAIT := True
	; SoundPlay "ding.wav" ; , WAIT := True
	PlaySound(Ring)
	FocusTerm()
}

