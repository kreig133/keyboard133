#SingleInstance
#include lib/Edit.ahk

index := 1 ; For built-in variable $i
k133Width  := 1000
k133Height := 750

Gui,Font,
Gui,Add,ComboBox,x13 y6 w970 vPattern hWndhPattern,
Gui,Add,ComboBox,x13 y35 w920 vReplaceBy,
Gui,Add,Edit,Limit Number x940 y35 w43 vIndex hWndhIndex,
Gui,Add,Edit,x13 y91 w970 h650 vTextInEditor hWndhEdit,
Gui +AlwaysOnTop

Return

Capslock & vk46:: ; Capslock + F
	oldClipboard := Clipboard

	Send, ^{vk43}
	Sleep, 50
	Edit_SetText(hEdit, Clipboard)

	centralPoint := GetCurrentMonitor().GetCentralPoint()
	newXCoordinate := centralPoint.x - k133Width/2
	newYCoordinate := centralPoint.y - k133Height/2

	Gui,Show,x%newXCoordinate% y%newYCoordinate% w%k133Width% h%k133Height%, keyboard133

	Clipboard := oldClipboard
	Return

GuiClose: 
	Gui, Hide
	Return

#IfWinActive keyboard133 ahk_class AutoHotkeyGUI
Escape::
	Gui, Hide
	Return

Ctrl & Enter::
	oldClipboard = %Clipboard%
	Gui, Submit
	Clipboard = %TextInEditor%
	Send, ^{vk56}
	Sleep, 50
	Clipboard = %oldClipboard%
	Return

F3:: ; Search ahead
	Gui, Submit, NoHide ;
	ControlFocus, , ahk_id %hEdit%
	SearchAhead(hEdit, Pattern)
	if( ! Edit_TextIsSelected(hEdit) )
	{
		ControlFocus, , ahk_id %hPattern%
	}
	Return

+F3:: ; Search behind
	;TODO
	Return

!vk50::  ; Alt + p —  Replace Current Selection
	Gui, Submit, NoHide ;

	if( ! Edit_TextIsSelected(hEdit) )
	{
		SearchAhead(hEdit, Pattern)
	}
	if( Edit_TextIsSelected(hEdit) )
	{
		Edit_GetSel(hEdit, $StartSelPos, $EndSelPos)
		Pattern := UpdatePattern()
		NewText := UpdateStrings(RegExReplace(Edit_GetSelText(hEdit), Pattern, ReplaceBy))
		Edit_ReplaceSel(hEdit, NewText)
		SearchAhead(hEdit, Pattern, $StartSelPos + StrLen(NewText))
	}
	Return

!vk41::  ; Alt+A — Replace All
	Gui, Submit, NoHide  ;
	Pattern := UpdatePattern()
	NewText := UpdateStrings( RegExReplace(TextInEditor, Pattern, ReplaceBy) ) ;
	GuiControl,,TextInEditor, %NewText%

	Return

SearchAhead(hEdit, Pattern, StartSearchPos = -1){
	textEditor := Edit_GetText(hEdit)
	Edit_GetSel(hEdit, $StartSelPos, $EndSelPos)
	
	Pattern := UpdatePattern()
	
	if( StartSearchPos < 0 )
	{
		FoundPos := RegExMatch(textEditor, Pattern, FindedText, $StartSelPos=$EndSelPos ? 1 : $EndSelPos+1)-1
	}
	else
	{
		FoundPos := RegExMatch(textEditor, Pattern, FindedText, StartSearchPos + 1)-1	
	}

	Edit_SetSel(hEdit, FoundPos, FoundPos + StrLen(FindedText) )
	; Scroll for visibility selected text	
	EM_SCROLLCARET := 0xB7
	SendMessage, EM_SCROLLCARET,,,, ahk_id %hEdit%
	
	Return
}

UpdateStrings(_stringForUpdate)
{
	global Index
	newString = ;
	Loop
	{
		newString := RegExReplace( _stringForUpdate, "(?<!\\)\$i", Index, 0, 1 )

		if _stringForUpdate = %newString% 
			Break
		else
			++Index

		_stringForUpdate := newString
	}

	GuiControl,,Index, %Index%

	  _result := RegExReplace( RegExReplace( RegExReplace( RegExReplace( RegExReplace(_stringForUpdate, "(?<!\\)\\n", "`n"), "(?<!\\)\\t", "`t" ), "(?<!\\)\\r", "`r"), "\\\\", "\"), "\\\$i", "$$i")
	  ; MsgBox, % "Before" _stringForUpdate "`nAfter" _result
	  Return _result
}

UpdatePattern()
{
	global Pattern
	Return RegExReplace(Pattern, "^([imsxADJUXPS`nra]+\))?(.*)$", "$1(*UCP)$2")
}

GetMonitorCount()
{
	SysGet, MonitorCount, MonitorCount
	Return MonitorCount
}

GetMonitorByIndex(_index)
{
	SysGet, Mon, Monitor, %_index%
	_lt := new Point(MonLeft , MonTop)
	_rt := new Point(MonRight, MonBottom)
	Return new Monitor(_lt, _rt)
}

GetCurrentMonitor()
{
	WinGetPos, _x, _y, _w, _h, A
	_window := new Window(new Point(_x,_y), new Point(_x+_w, _y+_h) )
	Loop, % GetMonitorCount()
	{
		_monitor := GetMonitorByIndex(A_Index)
		if(_monitor.ContainsPoint(_window.GetCentralPoint()))
		{
			Return _monitor
		}
	}
}

;ShowInformationAboutMonitors()
;{
;	Loop, % GetMonitorCount()
;	{
;		_monitor := GetMonitorByIndex(A_Index)
;		_monitor.Show()
;	}
;}

;ShowCentralPointOfMonitors()
;{
;	Loop, % GetMonitorCount()
;	{
;		_monitor := GetMonitorByIndex(A_Index)
;		_monitor.GetCentralPoint().Show()
;	}
;}

class Point
{
	__New(_x, _y)
	{
		this.x := _x
		this.y := _y
	}

	Show()
	{
		MsgBox, % "Point(" this.x ", " this.y ")"
	}
}

class Rectangle
{
	__New(_lt, _rd)
	{
		this.leftTop   := _lt
		this.rightDown := _rd
	}

	ContainsPoint(_point)
	{
		if( _point.x >= this.leftTop.x and _point.x <= this.rightDown.x and _point.y >= this.leftTop.y and _point.y <= this.rightDown.y)
		{
			Return true
		}

		Return false
	}

	GetCentralPoint()
	{
		_x := this.leftTop.x + (this.rightDown.x - this.leftTop.x) / 2
		_y := this.leftTop.y + (this.rightDown.y - this.leftTop.y) / 2
		Return new Point(_x, _y)
	}

	Show()
	{
		MsgBox, % "Monitor — LeftTop(" this.leftTop.x ", " this.leftTop.y "), RightDown("  this.rightDown.x ", " this.rightDown.y ")"
	}
}

class Window extends Rectangle
{

}

class Monitor extends Rectangle
{

}