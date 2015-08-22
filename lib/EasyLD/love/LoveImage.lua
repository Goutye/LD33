local class = require 'EasyLD.lib.middleclass'

local Image = require 'EasyLD.AdapterImage'

local LoveImage = class('LoveImage', Image)

function LoveImage:initialize(src, filter1, filter2)
	self.src = love.graphics.newImage(src)
	self.w = self.src:getWidth()
	self.h = self.src:getHeight()

	if filter1 == nil then
		self.src:setFilter("nearest", "nearest")
	elseif filter2 == nil then
		self.src:setFilter(filter1, filter1)
	else
		self.src:setFilter(filter1, filter2)
	end

	self.id = {}
	self.quad = {}
	self.batch = love.graphics.newSpriteBatch(self.src, 1)
end

function LoveImage:draw(x, y, r, sx, sy, ox, oy, kx, ky)
	if (ox == nil or oy == nil) and r ~= 0 then
		love.graphics.translate(x,y)
		love.graphics.rotate(r)
		love.graphics.translate(-x, -y)
		love.graphics.draw(self.src, x, y, 0)
		love.graphics.translate(x,y)
		love.graphics.rotate(-r)
		love.graphics.translate(-x, -y)
	elseif r ~= 0 then
		love.graphics.translate(ox,oy)
		love.graphics.rotate(r)
		love.graphics.translate(-ox, -oy)
		love.graphics.draw(self.src, x, y, 0)
		love.graphics.translate(ox,oy)
		love.graphics.rotate(-r)
		love.graphics.translate(-ox, -oy)
	else
		love.graphics.draw(self.src, x, y, r, sx, sy, ox, oy, kx, ky)
	end
end

function LoveImage:drawPart(mapX, mapY, x, y, w, h, id, angle)
	if angle == nil then
		angle = 0
	end
	if id ~= nil then
		if self.id[id] == nil then
			self.id[id] = true
			self.quad[id] = love.graphics.newQuad(x, y, w, h, self.w, self.h)
		end

		self.batch:bind()
		self.batch:clear()
		self.batch:add(self.quad[id], mapX, mapY)
		self.batch:unbind()

		love.graphics.translate(mapX, mapY)
		love.graphics.rotate(angle)
		love.graphics.translate(-mapX, -mapY)
		love.graphics.draw(self.batch, 0, 0)
		love.graphics.translate(mapX, mapY)
		love.graphics.rotate(-angle)
		love.graphics.translate(-mapX, -mapY)
	else
		local quad = love.graphics.newQuad(x, y, w, h, self.w, self.h)
		local batch = love.graphics.newSpriteBatch(self.src, 1)
		batch:bind()
		batch:clear()
		batch:add(quad, mapX, mapY)
		batch:unbind()

		love.graphics.draw(batch, 0, 0)
	end
end

return LoveImage