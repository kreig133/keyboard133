#include functions/arrows_fun.ahk

Capslock & Insert:: 

Send, Capslock
return
;
Capslock & Enter::

GetKeyState, altState, Alt
if altState = U
{
	Send, {End}
}
Arrows("{Enter}")
return
;
Capslock & i::

Arrows("{Up}")
return
;
Capslock & k::

Arrows("{Down}")
return
;
Capslock & j::

Arrows("{Left}")
return
;
Capslock & l::

Arrows("{Right}")
return
;
Capslock & u::

Arrows("{Home}")
return
;
Capslock & o::

Arrows("{End}")
return
;
Capslock & y::

Arrows("{PgUp}")
return
;
Capslock & p::

Arrows("{PgDn}")
return
;
Capslock & h::

Arrows("{BS}")
return
;
Capslock & `;::

Arrows("{Del}")
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

Arrows("{Raw}{")
return
;
Capslock & m::

Arrows("{Raw}}")
return
;
Capslock & ,::

Arrows("<")
return
;
Capslock & .::

Arrows(">")
return
;
Capslock & /::

Arrows("/")
return
;
Capslock & Space::

Arrows("{Click}")
return
;