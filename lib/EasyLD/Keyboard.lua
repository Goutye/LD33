local Keyboard = {
	pressed = {},
	released = {},
	down = {},
	downTime = {},
}
Keyboard.__index = Keyboard

function Keyboard.new()
	local self = setmetatable({}, Keyboard)

	self.last = nil
	self.lastChar = nil

	return self
end

function Keyboard:lastKeyPressed()
	return self.last
end

function Keyboard:keyPressed(key)
	self.pressed[key] = true
	self.down[key] = true
	self.downTime[key] = os.time()
	self.last = key
end

function Keyboard:keyReleased(key)
	self.released[key] = true
	self.down[key] = false
	self.downTime[key] = nil

	if self.last == key then
		self.last = nil
	end
end

function Keyboard:isPressed(key)
	return self.pressed[key] or false
end

function Keyboard:isDown(key)
	return self.down[key] or false
end

function Keyboard:isDownMoreThan(key,sec)
	if self.downTime[key] == nil then
		return false
	end
	return (os.time() - self.downTime[key]) >= sec
end

function Keyboard:isReleased(key)
	return self.released[key] or false
end

function Keyboard:reset()
	for key, value in pairs(self.pressed) do
		self.pressed[key] = false
	end
	for key, value in pairs(self.released) do
		self.released[key] = false
	end
	self.last = nil
end

return Keyboard:new()