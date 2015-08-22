local class = require 'EasyLD.lib.middleclass'

local Image = require 'EasyLD.AdapterImage'

local DrystalImage = class('DrystalImage', Image)

function DrystalImage:initialize(src, filter)
	self.src = assert(drystal.load_surface(src))
	self.w = self.src.w
	self.h = self.src.h

	if filter == "linear" then
		self.src.set_filter(drystal.filters.linear)
	elseif filter == "nearest" then
		self.src.set_filter(drystal.filters.nearest)
	elseif filter == "bilinear" then
		self.src.set_filter(drystal.filters.bilinear)
	elseif filter == "trilinear" then
		self.src.set_filter(drystal.filters.trilinear)
	end
end

function DrystalImage:draw(x, y, r, sx, sy, ox, oy)
	self.src:draw_from()

	if r ~= 0 then
		if ox == nil or oy == nil then
			ox, oy = x, y
		end
		drystal.draw_sprite_rotated({x=0, y=0, w=self.w, h=self.h}, x, y, r, ox-x, oy-y)
	else
		drystal.draw_image(0, 0, self.w, self.h, x, y)
	end
end

function DrystalImage:drawPart(mapX, mapY, x, y, w, h)
	self.src:draw_from()
	drystal.draw_image(x, y, w, h, mapX, mapY)
end

return DrystalImage