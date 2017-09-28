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
	local s = love.graphics.getCanvas()
	love.graphics.setCanvas(self.s)
	if clear then self:clear(true) end
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

function Surface:clear(bIsActive)
	if bIsActive then
		love.graphics.clear(0,0,0,0)
	else
		if bIsActive == nil then
			print("Surface is cleared when it is not the active Canvas. Bad Performance. Please improve if possible by clearing when the canvas is actived. Otherwise call Surface:clear(false)")
		end
		local temp = love.graphics.getCanvas()
		love.graphics.setCanvas(self.s)
		love.graphics.clear(0,0,0,0)
		love.graphics.setCanvas(temp)
	end
end

return Surface