local class = require 'EasyLD.lib.middleclass'

local Surface = class('Surface')

Surface.table = {}

function Surface.drawOnScreen()
	love.graphics.setCanvas(love.screen)
end

function Surface:initialize(w, h)
	self.w = w or EasyLD.window.w
	self.h = h or EasyLD.window.h
	self.s = love.graphics.newCanvas(self.w, self.h)
	EasyLD.surface.table[self.s] = self
end

function Surface:drawOn(clear)
	if clear then self:clear() end
	local s = love.graphics.getCanvas()
	love.graphics.setCanvas(self.s)
	if s == nil then return {drawOn = Surface.drawOnScreen} end
	return EasyLD.surface.table[s]
end

function Surface:draw(x, y, xs, ys, w, h, r)
	self.quad = love.graphics.newQuad(xs or 0, ys or 0, w or self.w, h or self.h, self.s:getWidth(), self.s:getHeight())
	love.graphics.draw(self.s, self.quad, x, y)
end

function Surface:setFilter(type)
	self.s:setFilter(type)
end

function Surface:getPixel(x, y)
	return EasyLD.color:new()
end

function Surface:clear()
	self.s:clear(0,0,0,0)
end

return Surface