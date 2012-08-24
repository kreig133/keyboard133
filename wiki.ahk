WikiConfHotKey(FirstWikiTag, SecondWikiTag = "")
{
	wtCl = %Clipboard%
	Send, {CTRLDOWN}{vk58}{CTRLUP}
	Send, {CTRLDOWN}{SHIFTDOWN}{vk44}{SHIFTUP}{CTRLUP}
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
	Send, {Tab}
	Send, {Enter}
	Clipboard = %wtCl%
	return 
}

#!q::
WikiConfHotKey("{Raw}{quote}")
return 

#!e::
WikiConfHotKey("{Raw}{expand}")
return 

#!c::o
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


#!r::
	tCl = %Clipboard%
	Send, {CTRLDOWN}{vk58}{CTRLUP}
	Send, {CTRLDOWN}{SHIFTDOWN}{vk44}{SHIFTUP}{CTRLUP}
	SendInput {Raw}{expand:Код PB}
	SendInput {Enter}

	SendInput {Raw}{code:lang=javascript}
	SendInput {Enter}

	Send {CTRLDOWN}{vk56}{CTRLUP}
	SendInput {Enter}
	SendInput {Raw}{code}
	SendInput {Enter}
	SendInput {Raw}{expand}
	SendInput {Enter}
	Send, {Tab}
	Send, {Enter}
	Clipboard = %tCl%
return

