#include functions/arrows_fun.ahk

Capslock & Insert:: 

Send, {Capslock}
return
;
Capslock & VK0D:: ; Capslock + Enter

GetKeyState, altState, Alt
if altState = U
{
	Send, {End}
}
Arrows("{Enter}")
return
;
Capslock & VK49:: ; Capslock + i

Arrows("{Up}")
return
;
Capslock & VK4b:: ; Capslock + k

Arrows("{Down}")
return
;
Capslock & VK4A:: ; Capslock + j

Arrows("{Left}")
return
;
Capslock & VK4C:: ; Capslcok + l

Arrows("{Right}")
return
;
Capslock & VK55:: ; Capslock + u

Arrows("{Home}")
return
;
Capslock & VK4F:: ; Capslock + o

Arrows("{End}")
return
;
Capslock & VK59:: ; Capslock + y

Arrows("{PgUp}")
return
;
Capslock & VK50:: ; Capslock + p

Arrows("{PgDn}")
return
;
Capslock & VK48:: ; Capslock + h

Arrows("{BS}")
return
;
Capslock & VKBA:: ; Capslock + ;

Arrows("{Del}")
return
