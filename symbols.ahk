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

SendInput, {Raw}¬
return
;
Capslock & 2::

SendInput, {Raw}@
return
;
Capslock & 3::

SendInput, {Raw}#
return
;
Capslock & 4::

SendInput, {Raw}$
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
