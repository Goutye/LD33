local class = require 'EasyLD.lib.middleclass'

local Font = class('Font')

Font.static.fonts = {}

function Font.static.print(text, id, size, box, modeW, modeH, color)
	EasyLD.font.fonts[id]:print(text, size, box, modeW, modeH, color)
end

function Font:initialize(src)
	self.src = src
	self.font = {}
	self.color = {}
	table.insert(EasyLD.font.fonts, self)
end

function Font:load(size, color)
	if self.font[size] == nil then
		self.font[size] = EasyLD.font.newFont(self.src, size)
	end
	if color ~= nil then
		self.color[size] = color or EasyLD.color:new(255,255,255)
	end
end

function Font:print(text, size, box, modeW, modeH, color)
	if text == "" or text == nil then
		return
	end

	self:load(size, color)
	if color ~= nil then
		self.color[size] = color
	end
	EasyLD.font.printAdapter(text, self.font[size], box, modeW, modeH, self.color[size])
end

function Font:printOutLine(text, size, box, modeW, modeH, color, colorOut, thickness)
	if text == "" or text == nil then
		return
	end

	self:load(size, color)
	if color ~= nil then
		self.color[size] = color
	end

	EasyLD.font.printOutLineAdapter(text, self.font[size], box, modeW, modeH, self.color[size], colorOut, thickness)
end

function Font:sizeOf(str, size)
	self:load(size)
	return EasyLD.font.sizeOfAdapter(self.font[size], str)	
end

return Font