#Requires AutoHotkey v2.0
#SingleInstance Force
#DllLoad "Imm32" ; for consoles compatibility, see docs.microsoft.com/en-us/windows/win32/api/imm/
; InstallKeybdHook
; KeyHistory
global imm := DllCall("GetModuleHandle", "Str","Imm32", "Ptr") ; better performance; lexikos.github.io/v2/docs/commands/DllCall.htm
global immGetDefaultIMEWnd := DllCall("GetProcAddress", "Ptr",imm, "AStr","ImmGetDefaultIMEWnd", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/imm/nf-imm-immgetdefaultimewnd


; add us english-us keyboard
; add russian keyboard
; add german-us keyboard
$#F11:: {
    SetInputLang(0x0419) ; 67699721
}

$#F12:: {
    SetInputLang(0x0407) ; de-de
}

$#F10:: {
    SetInputLang(0x0409) ; english-ÜS
}


SetInputLang(Lang)
{
    hWnd := WinActive("A")
    PostMessage(0x50, 0, Lang, hWnd)
}



F13::{
    MouseMove(-20, 0, 50, "R")
}

F14::{
    MouseMove(20, 0, 50, "R")
}

F15::{
    MouseMove(0, -20, 50, "R")
}
F16::{
    MouseMove(0, 20, 50, "R")
}

F17::{
    MouseClick()
}
F18::{
    MouseClick("Right")
}
F19::{
    MouseClick("WU")
}

F20::{
    MouseClick("WD")
}

GetInputLocaleID() {
	foregroundWindow := DllCall("GetForegroundWindow") ; docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow

	isConsole := WinActive("ahk_class ConsoleWindowClass") ; CMD, Powershell
	isVGUI := WinActive("ahk_class vguiPopupWindow") ; Popups
	isUWP := WinActive("ahk_class ApplicationFrameWindow") ; Steam, UWP apps: autohotkey.com/boards/viewtopic.php?f=76&t=69414

	if isConsole {
		IMEWnd := DllCall(immGetDefaultIMEWnd, "Ptr",foregroundWindow) ; DllCall("Imm32.dll\ImmGetDefaultIMEWnd", "Ptr",fgWin)
		if (IMEWnd == 0) {
			return
		} else {
			foregroundWindow := IMEWnd
		}
	} else if isVGUI or isUWP {
		Focused	:= ControlGetFocus("A")
		if (Focused == 0) {
			return
		} else {
			ctrlID := ControlGetHwnd(Focused, "A")
			foregroundWindow := ctrlID
		}
	}
	threadId := DllCall("GetWindowThreadProcessId", "Ptr",foregroundWindow , "Ptr",0) ; docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowthreadprocessid
	inputLocaleId := DllCall("GetKeyboardLayout", "UInt",threadId) ; precise '0xfffffffff0c00409' value

	return inputLocaleId
}