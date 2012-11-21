Symbols(NormalMode, Shifted )
{
	GetKeyState, symShiftState, Shift
	if symShiftState = D
		SendInput, %Shifted%
	else
		SendInput, %NormalMode% 
	return
}

Capslock & Tab::
Send, {Space 4}
return

Capslock & vkC0:: ; Capslock + `

Symbols("{Raw}~", "{Raw}``")
return
;
Capslock & VK31:: ; Capslock + 1

Symbols("{Raw}¬", "{Raw}¹") 
return
;
Capslock & VK32:: ; Capslock + 2

Symbols("{Raw}@", "{Raw}²") 
return
;
Capslock & VK33:: ; Capslock + 3

Symbols("{Raw}#", "{Raw}³") 
return
;
Capslock & VK34:: ; Capslock + 4

Symbols("{Raw}$", "{Raw}€") 
return
;
Capslock & VK35:: ; Capslock + 5

SendInput, {Raw}‰
return
;
Capslock & VK36:: ; Capslock + 6

SendInput, {Raw}^
return
;
Capslock & VK37:: ; Capslock + 7

SendInput, {Raw}&
return
;
Capslock & VK38:: ; Capslock + 8

Symbols("{Raw}·", "{Raw}×")
return
;
Capslock & VK39:: ; Capslock + 9

SendInput, {Raw}«
return
;
Capslock & VK30:: ; Capslock + 0

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
Capslock & VKDB:: ; Capslock + [

SendInput, [
return
;
Capslock & VKDD:: ; Capslock + ]

SendInput, ]
return
;
Capslock & VK4E:: ; Capslock + n

SendInput, {Raw}{
return
;
Capslock & VK4D:: ; Capslock + m

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
Capslock & vkBC:: ; Capslock + ,

Symbols("{Raw}<", "{Raw}≤") 
return
;
Capslock & vkBE:: ; Capslcok + .

Symbols("{Raw}>", "{Raw}≥") 
return
;
Capslock & vk5A:: ; Capslock + z

Symbols("Ѣ", "ѣ")
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
