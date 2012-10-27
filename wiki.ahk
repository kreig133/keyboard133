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

#!vk51 up:: ; Q
WikiConfHotKey("{Raw}{quote}")
return 

#!vk45 up:: ; E
WikiConfHotKey("{Raw}{expand}")
return 

#!vk4E up:: ; N
WikiConfHotKey("{Raw}{note}")
return 

#!vk49 up:: ; I
WikiConfHotKey("{Raw}{info}")
return 

#!vk54 up:: ; T
WikiConfHotKey("{Raw}{tip}")
return 

#!vk57 up:: ; W
WikiConfHotKey("{Raw}{warning}")
return 

#!vk50 up:: ; P
WikiConfHotKey("{Raw}{panel}")
return 

#!vk4D up:: ; M
	SaveSelectedText()
	SendInput, {Raw}{{%Clipboard%
	Sleep, 50
	SendInput, {Raw}}}
	Clipboard := tCl
return

#!vk41 up:: ; A
	SaveSelectedText()
	OpenWikiDialog()
	SendInput, {Raw}{anchor:%Clipboard%}
	;
	CloseWikiDialogAndRestoreClipboard()
return 


#!vk52 up:: ; R
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

#!vk4C up:: ; L
	SaveSelectedText()
	OpenWikiDialog()
	SendInput, {Raw}[%Clipboard%|%tCl%#%Clipboard%]
	CloseWikiDialogAndRestoreClipboard()
return 

#!vk56 up:: ; V
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
	
#!vk43 up:: ; C
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
