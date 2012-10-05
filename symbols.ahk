Symbols(NormalMode, Shifted )
{
	GetKeyState, symShiftState, Shift
	if symShiftState = D
		SendInput, %Shifted%
	else
		SendInput, %NormalMode% 
	return
}


Capslock & SC029::

Symbols("{Raw}~", "{Raw}``")
return
;
Capslock & 1::

Symbols("{Raw}¬", "{Raw}¹") 
return
;
Capslock & 2::

Symbols("{Raw}@", "{Raw}²") 
return
;
Capslock & 3::

Symbols("{Raw}#", "{Raw}³") 
return
;
Capslock & 4::

Symbols("{Raw}$", "{Raw}€") 
return
;
Capslock & 5::

SendInput, {Raw}‰
return
;
Capslock & 6::

SendInput, {Raw}^
return
;
Capslock & 7::

SendInput, {Raw}&
return
;
Capslock & 8::

Symbols("{Raw}·", "{Raw}×")
return
;
Capslock & 9::

SendInput, {Raw}«
return
;
Capslock & 0::

SendInput, {Raw}»
return
;
Capslock & =::

Symbols("{Raw}≠", "{Raw}±")
return
;
Capslock & \::

SendInput, {Raw}|
return
;
Capslock & -::

Symbols("{Raw}–", "{Raw}—") 
return
;
;
Capslock & [::

SendInput, [
return
;
Capslock & ]::

SendInput, ]
return
;
Capslock & n::

SendInput, {Raw}{
return
;
Capslock & m::

SendInput, {Raw}}
return
;
Capslock & /::

Symbols("{Raw}/", "{Raw}÷") 
return
;
Capslock & Space::

SendInput, {Click}
return
;
Capslock & vkBC::

Symbols("{Raw}<", "{Raw}≤") 
return
;
Capslock & vkBE::

Symbols("{Raw}>", "{Raw}≥") 
return
;

:?:->::→
;
:?:<-::←
;
:?:(c)::©
;
:?:(r)::®
;
:?:...::…
;
:?:(TM)::™
