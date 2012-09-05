SaveSelectedTextAndOpenWikiDialog()
{
	global tCl
	tCl := Clipboard	
	Sleep, 50
	Send, {CTRLDOWN}{vk58}{CTRLUP}
	Send, {CTRLDOWN}{SHIFTDOWN}{vk44}{SHIFTUP}{CTRLUP}
}

CloseWikiDialogAndRestoreClipboard()
{
	global tCl
	Send, {Tab}	
	Send, {Enter}
	Clipboard := tCl
}

WikiConfHotKey(FirstWikiTag, SecondWikiTag = "")
{
	SaveSelectedTextAndOpenWikiDialog()
	SendInput %FirstWikiTag%
	SendInput {Enter}
	if SecondWikiTag <>
	{
		SendInput %SecondWikiTag%
		SendInput {Enter}
	}
	Send {CTRLDOWN}{vk56}{CTRLUP}
	SendInput {Enter}
	if SecondWikiTag <>			
	{
		SendInput %SecondWikiTag%
		SendInput {Enter}
	}
	SendInput %FirstWikiTag%
	SendInput {Enter}
	CloseWikiDialogAndRestoreClipboard()
	return 
}

#!q::
WikiConfHotKey("{Raw}{quote}")
return 

#!e::
WikiConfHotKey("{Raw}{expand}")
return 

#!c::
WikiConfHotKey("{Raw}{code}")
return 

#!n::
WikiConfHotKey("{Raw}{note}")
return 

#!i::
WikiConfHotKey("{Raw}{info}")
return 

#!t::
WikiConfHotKey("{Raw}{tip}")
return 

#!w::
WikiConfHotKey("{Raw}{warning}")
return 

#!p::
WikiConfHotKey("{Raw}{panel}")
return 

#!a::
	SaveSelectedTextAndOpenWikiDialog()
	SendInput, {Raw}{anchor:%Clipboard%}
	;
	CloseWikiDialogAndRestoreClipboard()
return 


#!r::
	SaveSelectedTextAndOpenWikiDialog()
	SendInput {Raw}{expand:Код PB}
	SendInput {Enter}

	SendInput {Raw}{code:lang=javascript}
	SendInput {Enter}

	SendInput, %Clipboard%
	SendInput {Enter}
	SendInput {Raw}{code}
	SendInput {Enter}
	SendInput {Raw}{expand}
	SendInput {Enter}
	CloseWikiDialogAndRestoreClipboard()
return

#!l::
	SaveSelectedTextAndOpenWikiDialog()
	SendInput, {Raw}[%Clipboard%|%tCl%#%Clipboard%]
	CloseWikiDialogAndRestoreClipboard()
return 