SaveSelectedText()
{
    KeyWait, Lwin
    KeyWait, Rwin
    KeyWait, Alt
	global tCl
	tCl := Clipboard	
	Sleep, 50
	Send, {CTRLDOWN}{vk58}{CTRLUP}
	Sleep, 50
}

OpenWikiDialog()
{
	Send, {CTRLDOWN}{SHIFTDOWN}{vk44}{SHIFTUP}{CTRLUP}
}

CloseWikiDialogAndRestoreClipboard()
{
	global tCl
	Send, {Tab}	
	Send, {Space}
	Clipboard := tCl
}

WikiConfHotKey(FirstWikiTag, SecondWikiTag = "")
{
	SaveSelectedText()
	OpenWikiDialog()
	SendInput %FirstWikiTag%
	if SecondWikiTag <>
	{
		SendInput %SecondWikiTag%
		SendInput {Enter}
	}
	Send {CTRLDOWN}{vk56}{CTRLUP}
	Sleep, 50
	if SecondWikiTag <>			
	{
		SendInput %SecondWikiTag%
		SendInput {Enter}
	}
	SendInput %FirstWikiTag%
	CloseWikiDialogAndRestoreClipboard()
	return 
}

#!q up::
WikiConfHotKey("{Raw}{quote}")
return 

#!e up::
WikiConfHotKey("{Raw}{expand}")
return 

#!n up::
WikiConfHotKey("{Raw}{note}")
return 

#!i up::
WikiConfHotKey("{Raw}{info}")
return 

#!t up::
WikiConfHotKey("{Raw}{tip}")
return 

#!w up::
WikiConfHotKey("{Raw}{warning}")
return 

#!p up::
WikiConfHotKey("{Raw}{panel}")
return 

#!m up::
	SaveSelectedText()
	SendInput, {Raw}{{%Clipboard%
	Sleep, 50
	SendInput, {Raw}}}
	Clipboard := tCl
return

#!a up::
	SaveSelectedText()
	OpenWikiDialog()
	SendInput, {Raw}{anchor:%Clipboard%}
	;
	CloseWikiDialogAndRestoreClipboard()
return 


#!r up::
	SaveSelectedText()
	OpenWikiDialog()
	SendInput {Raw}{expand:Код PB}
	SendInput {Enter}
	SendInput {Raw}{code:lang=javascript}
	SendInput {Enter}
	Send {CTRLDOWN}{vk56}{CTRLUP}
	Sleep, 50
	SendInput {Enter}
	SendInput {Raw}{code}
	SendInput {Enter}
	SendInput {Raw}{expand}
	SendInput {Enter}
	CloseWikiDialogAndRestoreClipboard()
return

#!l up::
	SaveSelectedText()
	OpenWikiDialog()
	SendInput, {Raw}[%Clipboard%|%tCl%#%Clipboard%]
	CloseWikiDialogAndRestoreClipboard()
return 

#!v up::
	SaveSelectedText()
	OpenWikiDialog()
	SendInput {Raw}{expand:Показать список исходящих ссылок}
	SendInput {Enter}
	SendInput {Raw}{incoming-links}
	SendInput {Enter}
	SendInput {Raw}{expand}
	SendInput {Enter}
	CloseWikiDialogAndRestoreClipboard()
return
	
#!c up::
	SaveSelectedText()
	OpenWikiDialog()
	SendInput {Raw}{code:lang=javascript}
	SendInput {Enter}
	Send {CTRLDOWN}{vk56}{CTRLUP}
	Sleep, 50
	SendInput {Enter}
	SendInput {Raw}{code}
	CloseWikiDialogAndRestoreClipboard()
return 
