local class = require 'EasyLD.lib.middleclass'

local InputText = class('InputText')

function InputText:initialize(box, colorBack, colorText, charLimit, font, size)
	self.box = box
	self.cBack = colorBack
	self.cText = colorText
	self.text = ""
	self.lastKey = nil
	self.focus = false
	self.nbChar = charLimit or 10
	self.font = font or EasyLD.font.fonts[1]
	self.fontSize = size or 16
end

function InputText:update(dt)
	if EasyLD.mouse:isPressed("l") then
		if EasyLD.collide:AABB_point(self.box, EasyLD.mouse:getPosition()) then
			self.focus = true
		else
			self.focus = false
		end
	end

	if self.focus then
		local key = EasyLD.keyboard:lastKeyPressed()

		if key ~= nil and self.lastKey ~= key then
			if string.len(key) == 1 and string.utf8len(self.text) < self.nbChar then
				self.text = self.text .. EasyLD.keyboard.lastChar
			elseif key == "backspace" then
				if string.utf8len(self.text) == 1 then
					self.text = ""
				else
					self.text = string.utf8sub(self.text, 0, -2)
				end
			elseif key == "space" then
				self.text = self.text .. " "
			end

			if self.font:sizeOf(self.text, self.fontSize) > self.box.w then
				self.text = string.utf8sub(self.text, 0, -2)
			end

			self.lastKey = key
		elseif self.lastKey ~= nil and EasyLD.keyboard:isReleased(self.lastKey) then
			self.lastKey = nil
		end
	end
end

function InputText:draw()
	self.box.c = self.cBack
	self.box:draw("fill")
	self.box.c = self.cText
	self.box:draw("line")
	self.font:print(self.text, self.fontSize, self.box, nil, "center", self.cText)
end

return InputText