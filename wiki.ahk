SaveSelectedTextAndOpenWikiDialog()
{
    KeyWait, Lwin
    KeyWait, Rwin
    KeyWait, Alt
	global tCl
	tCl := Clipboard	
	Sleep, 50
	Send, {CTRLDOWN}{vk58}{CTRLUP}
	Sleep, 50
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
	SaveSelectedTextAndOpenWikiDialog()
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
	SaveSelectedTextAndOpenWikiDialog()
	SendInput, {Raw}{{%Clipboard%}}
	;
	CloseWikiDialogAndRestoreClipboard()
return

#!a up::
	SaveSelectedTextAndOpenWikiDialog()
	SendInput, {Raw}{anchor:%Clipboard%}
	;
	CloseWikiDialogAndRestoreClipboard()
return 


#!r up::
	SaveSelectedTextAndOpenWikiDialog()
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
	SaveSelectedTextAndOpenWikiDialog()
	SendInput, {Raw}[%Clipboard%|%tCl%#%Clipboard%]
	CloseWikiDialogAndRestoreClipboard()
return 

#!v up::
	SaveSelectedTextAndOpenWikiDialog()
	SendInput {Raw}{expand:Показать список исходящих ссылок}
	SendInput {Enter}
	SendInput {Raw}{incoming-links}
	SendInput {Enter}
	SendInput {Raw}{expand}
	SendInput {Enter}
	CloseWikiDialogAndRestoreClipboard()
return
	
#!c up::
	SaveSelectedTextAndOpenWikiDialog()
	SendInput {Raw}{code:lang=javascript}
	SendInput {Enter}
	Send {CTRLDOWN}{vk56}{CTRLUP}
	Sleep, 50
	SendInput {Enter}
	SendInput {Raw}{code}
	CloseWikiDialogAndRestoreClipboard()
return 
