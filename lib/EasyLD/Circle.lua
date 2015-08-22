local class = require 'EasyLD.lib.middleclass'

local Matrix = require 'EasyLD.Matrix'
local Vector = require 'EasyLD.Vector'

local Shape = require 'EasyLD.Shape'

local Circle = class('Circle', Shape)

function Circle:initialize(x, y, r, c, mode)
	self.x = x
	self.y = y
	self.r = r
	self.c = c or EasyLD.color:new(255,255,255)
	self.mode = mode or "fill"
	self.angle = 0

	if c == nil then
		self.c = EasyLD.color:new(255,255,255)
	end
end

function Circle.__add(c, v)
	if type(c) == "table" and c.r ~= nil and type(v) == "table" then
		return Circle:new(c.x + v.x, c.y + v.y, c.r, c.c)
	else
		return c
	end
end

function Circle.__sub(c, v)
	if type(c) == "table" and c.r ~= nil and type(v) == "table" then
		return Circle:new(c.x - v.x, c.y - v.y, c.r, c.c)
	else
		return c
	end
end

function Circle:moveTo(x, y)
	self.x = x
	self.y = y
end

function Circle:translate(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Circle:draw(mode, nbSeg)
	if mode == nil then
		mode = self.mode
	end

	if self.img == nil then
		EasyLD.graphics:circle(mode, self, nbSeg, self.c)
	else
		if self.imgType == "center" then
			local zW = Vector:new(1, 0)
			local zH = Vector:new(0, 1)
			zW:rotate(self.angle)
			zH:rotate(self.angle)
			zW = zW * self.img.w/2
			zH = zH * self.img.h/2
			local x = self.x  - zW.x - zH.x
			local y = self.y - zH.y - zW.y
			self.img:draw(x, y, self.angle)
		else
			self.img:draw(self.x, self.y, self.angle)
		end
	end
end

function Circle:rotate(angle, ox, oy)
	local p = EasyLD.point:new(self.x, self.y)
	p:rotate(angle, ox, oy)

	self.x = p.x
	self.y = p.y
	self.angle = self.angle + angle
end

function Circle:copy()
	return Circle:new(self.x, self.y, self.r, self.c:copy(), self.mode)
end

--EasyLD.collide functions
function Circle:collide(area)
	return area:collideCircle(self)
end

function Circle:collideArea(area)
	return area:collideCircle(self)
end

function Circle:collidePolygon(poly)
	return EasyLD.collide:Polygon_circle(poly, self)
end

function Circle:collideBox(b, inside)
	if inside then
		return EasyLD.collide:Circle_inAABB(self, b)
	elseif b.angle == 0 then
		return EasyLD.collide:AABB_circle(b, self)
	else
		return EasyLD.collide:OBB_circle(b, self)
	end
end

function Circle:collideCircle(c)
	return EasyLD.collide:Circle_circle(self, c)
end

function Circle:collideSegment(s)
	return EasyLD.collide:Circle_segment(self, s)
end

function Circle:collidePoint(p)
	return EasyLD.collide:Circle_point(self, p)
end

return Circle