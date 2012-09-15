#SingleInstance
#include lib/Edit.ahk

index := 1

Gui,Font,
Gui,Add,ComboBox,x13 y6 w700 vPattern hWndhPattern,
Gui,Add,ComboBox,x13 y35 w650 vReplaceBy,
Gui,Add,Edit,Limit Number x670 y35 w43 vIndex hWndhIndex,
Gui,Add,Edit,x13 y91 w700 h224 vTextInEditor hWndhEdit,
Gui +AlwaysOnTop

Return

Capslock & f::
	oldClipboard = %Clipboard%

	Send, ^{vk43}
	Sleep, 50
	Edit_SetText(hEdit, Clipboard)

	CoordMode , Mouse, Screen
	MouseGetPos, mX, mY

	Gui,Show,x%mX% y%mY% w720 h308, keyboard133

	Clipboard = %oldClipboard%
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
	
	Return

!p::  ; Replace Current Selection
	Gui, Submit, NoHide ;

	if( ! Edit_TextIsSelected(hEdit) )
	{
		SearchAhead(hEdit, Pattern)
	}
	if( Edit_TextIsSelected(hEdit) )
	{
		Edit_GetSel(hEdit, $StartSelPos, $EndSelPos)
		Pattern := UpdatePattern()
		NewText := RegExReplace(Edit_GetSelText(hEdit), Pattern, ReplaceBy)
		Edit_ReplaceSel(hEdit, NewText)
		SearchAhead(hEdit, Pattern, $StartSelPos + StrLen(NewText))
	}
	Return

!a::  ; Replace All
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

	Return  RegExReplace( RegExReplace( RegExReplace( RegExReplace( RegExReplace(_stringForUpdate, "(?<!\\)\\n", "`n"), "(?<!\\)\\t", "`t" ), "(?<!\\)\\r", "`r"), "\\\\", "\"), "\\\$i", "$$i")
}

UpdatePattern()
{
	global Pattern
	Return RegExReplace(Pattern, "^([imsxADJUXPS`nra]+\))?(.*)$", "$1(*UCP)$2")
}

