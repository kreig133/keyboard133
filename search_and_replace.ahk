#SingleInstance
#include lib/Edit.ahk

Gui,Font,
Gui,Add,ComboBox,x13 y6 w700 vPattern,
Gui,Add,ComboBox,x13 y35 w700 vReplaceBy,
Gui,Add,Edit,x13 y91 w700 h224 vTextInEditor hWndhEdit,
Gui +AlwaysOnTop

Return

Capslock & f::
	oldClipboard = %Clipboard%

	Send, ^{vk43}
	Edit_SetText(hEdit, Clipboard)

	Gui,Show,x466 y466 w720 h308, keyboard133

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
	Clipboard:=Edit_GetText(hEdit)
	Gui, Hide
	Send, ^{vk56}
	Clipboard = %oldClipboard%
	Return

F3:: ; Search ahead
	Gui, Submit, NoHide ;
	SearchAhead(hEdit, Pattern)
	Return

+F3:: ; Search behind
	
	Return

!r::  ; Activate/Deactivate Regex Mode 
	MsgBox, Alt + Return
	Return

!c::  ; Activate/Deactivate Case Sensitive Mode
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
		NewText := RegExReplace(Edit_GetSelText(hEdit), Pattern, ReplaceBy)
		Edit_ReplaceSel(hEdit, NewText)
		SearchAhead(hEdit, Pattern, $StartSelPos + StrLen(NewText))
	}
	Return

!a::  ; Replace All
	Gui, Submit, NoHide  ;
	NewText := RegExReplace(TextInEditor, Pattern, ReplaceBy)  ;
	GuiControl,,TextInEditor, %NewText%

	Return

SearchAhead(hEdit, Pattern, StartSearchPos = -1){
	textEditor := Edit_GetText(hEdit)
	Edit_GetSel(hEdit, $StartSelPos, $EndSelPos)
	
	if( StartSearchPos < 0 )
	{
		FoundPos := RegExMatch(textEditor, Pattern, FindedText, $StartSelPos=$EndSelPos ? 1 : $EndSelPos+1)-1
	}
	else
	{
		FoundPos := RegExMatch(textEditor, Pattern, FindedText, StartSearchPos + 1)-1	
	}

	Edit_SetSel(hEdit, FoundPos, FoundPos + StrLen(FindedText) )
	Return
}