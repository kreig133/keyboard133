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
	temp = %Clipboard%
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
	Clipboard = %temp%
	return 
return


WikiConfHotKey(FirstTag, SecondTag = "")
{
	temp = %Clipboard%
	Send, {CTRLDOWN}{vk58}{CTRLUP}
	Send, {CTRLDOWN}{SHIFTDOWN}{vk44}{SHIFTUP}{CTRLUP}
	SendInput %FirstTag%
	SendInput {Enter}
	if SecondTag <>
	{
		SendInput %SecondTag%
		SendInput {Enter}
	}
	Send {CTRLDOWN}{vk56}{CTRLUP}
	SendInput {Enter}
	if SecondTag <>			
	{
		SendInput %SecondTag%
		SendInput {Enter}
	}
	SendInput %FirstTag%
	SendInput {Enter}
	Send, {Tab}
	Send, {Enter}
	Clipboard = %temp%
	return 
}