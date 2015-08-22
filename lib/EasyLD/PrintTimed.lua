local class = require 'EasyLD.lib.middleclass'

local PrintTimed = class('PrintTimed')

function PrintTimed:initialize(text, font, argsFont, typeTimed, time, timeBefore, timeAfter)
	self.text = text
	self.timeBefore = timeBefore or 0
	self.time = time + self.timeBefore
	self.timeAfter = (timeAfter or 0) + self.time
	self.typeTimed = typeTimed or "permanent"
	self.startAfter = self.typeTimed ~= "permanent"
	self.argsFont = argsFont
	self.alpha = argsFont[5].a
	self.currentTime = 0
	self.font = font
end

function PrintTimed:update(dt)
	self.currentTime = self.currentTime + dt
end

function PrintTimed:print()
	if self.currentTime < self.timeBefore then

	elseif self.currentTime >= self.timeBefore and self.currentTime < self.time then
		local text = string.sub(self.text, 0, math.floor((self.currentTime - self.timeBefore)/ (self.time - self.timeBefore) * string.len(self.text)))
		self.font:print(text, unpack(self.argsFont))
	elseif self.currentTime >= self.time and self.currentTime < self.timeAfter and self.startAfter then
		self.argsFont[5].a = self.alpha - self.alpha * ( (self.currentTime - self.time)/(self.timeAfter - self.time))
		self.font:print(self.text, unpack(self.argsFont))
	else
		self.font:print(self.text, unpack(self.argsFont))
	end
end

function PrintTimed:startEnd(time)
	self.startAfter = true
	self.timeAfter = self.time + time
	self.currentTime = self.time
end

return PrintTimed