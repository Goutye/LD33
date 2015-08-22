local class = require 'EasyLD.lib.middleclass'

local Shape = require 'EasyLD.Shape'

local Vector = require 'EasyLD.Vector'
local Segment = class('Segment', Shape)

function Segment:initialize(p1, p2, color)
	self.p1 = p1
	self.p2 = p2
	self.c = color or EasyLD.color:new(255,255,255)
	self.x = p1.x
	self.y = p1.y
	self.angle = 0 --TODO Angle segment from P1 P2
end

function Segment:translate(dx, dy)
	self.p1:translate(dx, dy)
	self.p2:translate(dx, dy)
	self.x = self.p1.x
	self.y = self.p1.y
end

function Segment:rotate(angle, ox, oy)
	self.p1:rotate(angle, ox, oy)
	self.p2:rotate(angle, ox, oy)
	self.x = self.p1.x
	self.y = self.p1.y
	self.angle = self.angle + angle
end

function Segment:moveTo(x, y)
	local dx, dy = x - self.p1.x, y - self.p1.y

	self:translate(dx, dy)
end

function Segment:draw()
	if self.img == nil then
		EasyLD.graphics:line(self.p1, self.p2, self.c)
	else
		if self.imgType == "center" then
			local zW = Vector:new(1, 0)
			local zH = Vector:new(0, 1)
			zW:rotate(self.angle)
			zH:rotate(self.angle)
			zW = zW * self.img.w/2
			zH = zH * self.img.h/2
			local x = self.x + (self.p2.x - self.p1.x)/2 - zW.x - zH.x
			local y = self.y + (self.p2.y - self.p1.y)/2 - zH.y - zW.y
			self.img:draw(x, y, self.angle)
		else
			self.img:draw(self.x, self.y, self.angle)
		end
	end
end

function Segment:copy()
	return Segment:new(self.p1:copy(), self.p2:copy(), self.c:copy())
end

--EasyLD.collide functions
function Segment:collide(area)
	return area:collideSegment(self)
end

function Segment:collideArea(area)
	return area:collideSegment(self)
end

function Segment:collidePolygon(poly)
	return EasyLD.collide:Polygon_segment(poly, self)
end

function Segment:collideBox(b)
	return EasyLD.collide:OBB_segment(b, self)
end

function Segment:collideCircle(c)
	return EasyLD.collide:Circle_segment(c, self)
end

function Segment:collideSegment(s)
	return EasyLD.collide:Segment_segment(s, self)
end

function Segment:collidePoint(p)
	return EasyLD.collide:Segment_point(self, p)
end

return Segment