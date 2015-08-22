local class = require 'EasyLD.lib.middleclass'

local Surface = class('Surface')

Surface.table = {}

local function powerOfTwo(x)
	return x == 1 or x == 2 or x == 4 or x == 8 or x == 16 or x == 32 or x == 64
		or x == 128 or x == 256 or x == 512 or x == 1024 or x == 2048 or x == 4096 --MaxSize = 2048
end

function Surface.drawOnScreen()
	drystal.screen:draw_on()
end

function Surface:initialize(w, h)
	self.w = w or EasyLD.window.w
	self.h = h or EasyLD.window.h
	if w == h and powerOfTwo(w) then
		self.s = drystal.new_surface(self.w, self.h)
	else
		self.s = drystal.new_surface(self.w, self.h, true)
	end
	EasyLD.surface.table[self.s] = self
end

function Surface:drawOn(clear)
	if clear then self:clear() end
	local s = self.s:draw_on()
	if EasyLD.surface.table[s] == nil then
		local surf = Surface:new()
		surf.s = s
		EasyLD.surface.table[s] = surf
		return surf
	else
		return EasyLD.surface.table[s]
	end
end

function Surface:draw(x, y, xs, ys, w, h, r)
	self.s:draw_from()
	drystal.draw_sprite_rotated({x=xs or 0, y=ys or 0, w=w or self.s.w, h=h or self.s.h}, x, y, r or 0)
end

function Surface:setFilter(type)
	self.s:set_filter(drystal.filters[type])
end

function Surface:getPixel(x, y)
	return EasyLD.color:new(self.s:get_pixel(x,y))
end

function Surface:clear()
	local old = self.s:draw_on()
	drystal.set_alpha(0)
	drystal.draw_background()
	drystal.set_color(255, 255, 255)
	drystal.set_alpha(255)
	old:draw_on()
end

return Surface