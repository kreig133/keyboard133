Capslock::return
;
Capslock & Enter::

GetKeyState, altState, Alt
if altState = U
{
	Send, {End}
}
Arrows("{Enter}", "{Enter}")
return
;
Capslock & d::

temp = Clipboard
Clipboard = ;
Send, ^{vk43}
StringLen, length, Clipboard
if length > 0 
{
	Send, ^{vk56}
	Send, ^{vk56}
}
else
{
	Send, {Home}
	Send, +{End}
	Send, ^{vk43}
	Send, {End}
	Send, {Enter}
	Send, ^{vk56}
}
Clipboard = %temp%
return
;
Capslock & i::

Arrows("{Up}", "8")
return
;
Capslock & k::

Arrows("{Down}", "5")
return
;
Capslock & j::

Arrows("{Left}", "4")
return
;
Capslock & l::

Arrows("{Right}", "6")
return
;
Capslock & u::

Arrows("{Home}", "7")
return
;
Capslock & o::

Arrows("{End}", "9")
return
;
Capslock & y::

Arrows("{PgUp}","{Raw}/")
return
;
Capslock & p::

Arrows("{PgDn}", "{Raw}*")
return
;
Capslock & h::

Arrows("{BS}")
return
;
Capslock & `;::

Arrows("{Del}", "{Raw}-")
return
;
Capslock & [::

Arrows("[")
return
;
Capslock & ]::

Arrows("]")
return
;
Capslock & n::

Arrows("{Raw}{", "{vk6E}")
return
;
Capslock & m::

Arrows("{Raw}}", "1")
return
;
Capslock & ,::

Arrows("<", "2")
return
;
Capslock & .::

Arrows(">", "3")
return
;
Capslock & /::

Arrows("/", "{Raw}+" )
return
;
Capslock & Space::

Arrows("{Click}", "0")
return
;
Capslock & =::
	SendInput, ≠
	return
;


Arrows(MainKey, NumKey = "NO_KEY")
{
	noKey = NO_KEY
	
	GetKeyState, shiftState, Shift
	GetKeyState, controlState, Control
	GetKeyState, altState, Alt

	if shiftState = D 
	{ 
		if controlState = D
			Send, ^+%MainKey%
		else
			Send, +%MainKey%
	}
	else if controlState = D
		Send, ^%MainKey%
	else if altState = D
	{
		
		if NumKey <> %noKey%
		{
			Send, %NumKey%
		}
		else
			return
	}
	else
		Send, %MainKey%
	return
}