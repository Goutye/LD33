local class = require 'EasyLD.lib.middleclass'

local Shape = require 'EasyLD.Shape'

local Vector = require 'EasyLD.Vector'
local Polygon = class('Polygon', Shape)

function Polygon:initialize(mode, color, ...)
	self.p = {...}
	self.c = color or EasyLD.color:new(255,255,255)
	self.mode = mode
	self.x = self.p[1].x
	self.y = self.p[1].y
	self.angle = 0
end

function Polygon:translate(dx, dy)
	for _,v in ipairs(self.p) do
		v:translate(dx, dy)
	end

	self.x = self.x + dx
	self.y = self.y + dy
end

function Polygon:rotate(angle, ox, oy)
	for _,v in ipairs(self.p) do
		v:rotate(angle, ox, oy)
	end

	self.x = self.p[1].x
	self.y = self.p[1].y
	self.angle = self.angle + angle
end

function Polygon:moveTo(x, y)
	local dx, dy = x - self.p[1].x, y - self.p[1].y
	self:translate(dx, dy)
end

function Polygon:barycenter()
	local bx, by = 0, 0

	for _,p in ipairs(self.p) do
		bx = bx + p.x
		by = by + p.y
	end

	return bx / #self.p, by / #self.p
end

function Polygon:draw()
	if self.img == nil then
		EasyLD.graphics:polygon(self.mode, self.c, unpack(self.p))
	else
		if self.imgType == "center" then
			local bx, by = self:barycenter()
			local zW = Vector:new(1, 0)
			local zH = Vector:new(0, 1)
			zW:rotate(self.angle)
			zH:rotate(self.angle)
			zW = zW * self.img.w/2
			zH = zH * self.img.h/2
			local x = bx - zW.x - zH.x
			local y = by - zH.y - zW.y
			self.img:draw(x, y, self.angle)
		else
			self.img:draw(self.x, self.y, self.angle)
		end
	end
end

function Polygon:copy()
	p = {}
	for _,v in ipairs(self.p) do
		table.insert(p, v:copy())
	end

	return Polygon:new(self.mode, self.c:copy(), unpack(p))
end

--EasyLD.collide functions
function Polygon:collide(area)
	return area:collidePolygon(self)
end

function Polygon:collideArea(area)
	return area:collidePolygon(self)
end

function Polygon:collidePolygon(poly)
	return EasyLD.collide:Polygon_polygon(poly, self)
end

function Polygon:collideBox(b)
	return EasyLD.collide:Polygon_OBB(self, b)
end

function Polygon:collideCircle(c)
	return EasyLD.collide:Polygon_circle(self, c)
end

function Polygon:collideSegment(s)
	return EasyLD.collide:Polygon_segment(self, s)
end

function Polygon:collidePoint(p)
	return EasyLD.collide:Polygon_point(self, p)
end

return Polygon