#Include focusTermRessource.ahk
#Include constantes.ahk

; Directly, because initiating powershell was half a second...
exePath      := EnvGet('LocalAppData') . "\wProjectDesktop\bin\VirtualDesktop.exe"
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
Ring := FileRead("..\Sounds\" . RingFile . ".wav", "RAW")
PlaySound(Sound) {
		DllCall("winmm.dll\PlaySound", "Ptr", Sound, "UInt", 0, "UInt", 0x5)
	; SoundPlay A_WinDir "\Media\ding.wav" ; , WAIT := True
	; SoundPlay "ding.wav" ; , WAIT := True
	}

F1::{
        MsgBox("F1")
	if WinExist(TERM){
	; See Discussions.txt
exitCode := RunWait('desktop_matches_state.bat', , "Hide")

switch exitCode {
    case 0:
        ; Desktop matches project
		PlaySound(Ring)
		FocusTerm()
    case 1:
        ; Desktop was changed out of wPD
		FocusTerm()
		Send('{F12}')
		PlaySound(Ring)
    case 2:
		; The state file doesn't exist. Meaning it's probably the first execution.
		PlaySound(Ring)
		FocusTerm()
    default:
        MsgBox("Unexpected error: " . exitCode)
}
	} else { ; If the user alt+F4d it for some reason
		RunWait 'powershell.exe -ExecutionPolicy Bypass -File ' . EnvGet("LocalAppData") . '\wProjectDesktop\src\Start-Term.ps1'
        MsgBox("ended")
	}
}

