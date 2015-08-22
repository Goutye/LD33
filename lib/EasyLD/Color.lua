local class = require 'EasyLD.lib.middleclass'

local Color = class('Color')

function Color:initialize(r, g, b, a)
	self.r = r
	self.g = g
	self.b = b
	self.a = a

	if self.a == nil then
		self.a = 255
	end
end

function Color:copy()
	return Color:new(self.r, self.g, self.b, self.a)
end

return Color