local Keyboard = {}

function drystal.key_press(key)
	EasyLD.keyboard:keyPressed(key)
end

function drystal.key_release(key)
	EasyLD.keyboard:keyReleased(key)
end

function drystal.key_text(key)
	EasyLD.keyboard.lastChar = key
end

return Keyboard