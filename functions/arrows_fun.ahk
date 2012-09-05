Arrows(MainKey)
{
	GetKeyState, shiftKeyState, Shift
	GetKeyState, controlKeyState, Control
	GetKeyState, altKeyState, Alt

	if shiftKeyState = D 
	{ 
		if controlKeyState = D
		{
			if altKeyState = D
				Send, ^+!%MainKey%
			else
				Send, ^+%MainKey%
		}	
		else
			Send, +%MainKey%
	}
	else if controlKeyState = D
	{
		if altKeyState = D
			Send, ^!%MainKey%
		else
			Send, ^%MainKey%
	}
	else if altKeyState = D
		Send, !%MainKey%
	else
		Send, %MainKey%
	return
}