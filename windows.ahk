#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#VK41:: ; Win + a
WinSet, AlwaysOnTop, Toggle, A ;
Return

LWin & WheelUp::
try 
{
	WinGet, currentTransparent, Transparent, A ;
}
catch e
{
	currentTransparent := 0
}	
currentTransparent:=currentTransparent - 10
if currentTransparent < 0
	currentTransparent := 0
try
{
	WinSet, Transparent, %currentTransparent%, A ;	
}
catch e
{
	WinSet, Transparent, %currentTransparent%, A ;
}
Return

LWin & WheelDown::
try 
{
	WinGet, currentTransparent, Transparent, A ;
}
catch e
{
	currentTransparent := 0
}	
currentTransparent:=currentTransparent + 10
if currentTransparent > 255
	currentTransparent := 255
try
{
	WinSet, Transparent, %currentTransparent%, A ;	
}
catch e
{
	WinSet, Transparent, %currentTransparent%, A ;
}
Return

!#VK53:: ; Win + Alt + s
WinActivate, Skype
Return