Capslock::return
;
Capslock & Enter::

Send, {End}
Arrows("{Enter}")
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

Arrows("{PgUp}")
return
;
Capslock & p::

Arrows("{PgDn}", "*")
return
;
Capslock & h::

Arrows("{BS}")
return
;
Capslock & `;::

Arrows("{Del}", "-")
return
;
Capslock & n::

Arrows("[")
return
;
;
Capslock & m::

Arrows("]", "1")
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

Arrows("/", "+" )
return
;
Capslock & Space::

Arrows("{Click}", "0")
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
		
		if NumKey =  *
		{
			Send, {vk6A}
		}
		else if NumKey = -
		{
			Send, {vk6D}
		}
		else if NumKey = +
		{
			Send, {vk6B}
		}
		else if NumKey <> %noKey%
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