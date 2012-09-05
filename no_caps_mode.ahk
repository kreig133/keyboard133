#include functions/arrows_fun.ahk



~Capslock::
	if Not (A_PriorHotkey <> "~Capslock" or A_TimeSincePriorHotkey > 300){
		noCapsModeOn := Not(noCapsModeOn)
	}
	Return

$*i::
	NoCapsMode("{Up}", "{vk49}")
	Return

$*k::
	NoCapsMode("{Down}", "{vk4B}")
	Return

$*j::
	NoCapsMode("{Left}", "{vk4A}")
	Return

$*l::
	NoCapsMode("{Right}","{vk4C}")	
	Return

$*h::
	NoCapsMode("{BS}", "{vk48}")
	Return

$*`;::
	NoCapsMode("{Del}", "{vkBA}")
	Return

NoCapsMode(_noCapsModeOn, _noCapsModeOff)
{
	global noCapsModeOn
	if noCapsModeOn
		Arrows(_noCapsModeOn)
	else
		Arrows(_noCapsModeOff)
	Return
}
