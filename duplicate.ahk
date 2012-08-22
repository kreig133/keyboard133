Capslock & d::

	try
	{
		ControlGetFocus, FocusedControl, A
		ControlGet, CurrentHWND, HWND, ,%FocusedControl%, A	
		Edit_Duplicate(CurrentHWND)
	}
	catch e
	{
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
	}


	return
;

