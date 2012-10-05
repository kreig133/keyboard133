#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.

noCapsModeOn := 0

#include lib/Edit.ahk
#include lib/Edit_Duplicate.ahk

#include navigation.ahk
#include symbols.ahk
#include duplicate.ahk
#include wiki.ahk
#include windows.ahk
;#include no_caps_mode.ahk



SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetCapsLockState AlwaysOff



*F12::
	MsgBox, % "LShift = " GetKeyState("LShift", "P") "`nLWin  = " GetKeyState("LWin", "P")  "`nLCtrl   = " GetKeyState("LCtrl", "P") "`nLAlt    = " GetKeyState("LAlt", "P")
	Return 