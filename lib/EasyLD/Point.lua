local class = require 'EasyLD.lib.middleclass'

local Shape = require 'EasyLD.Shape'

local Point = class('Point', Shape)

function Point.static:proj(p1, p2, pos)
	local v = EasyLD.vector:of(p1, p2)
	local v2 = EasyLD.vector:of(p1, pos)
	local norm = v:length()
	local dot = v:dot(v2) / (norm * norm)
	return p1 + (v * dot), dot
end

function Point.static:projDot(p1, axis, pos)
	local v2 = EasyLD.vector:of(p1, pos)
	local norm = axis:length()
	return axis:dot(v2) / (norm * norm)
end

function Point:initialize(x, y, collide, color)
	self.x = x
	self.y = y
	self.c = color or EasyLD.color:new(255,255,255)
	self.angle = 0
	if collide ~= nil then
		self.checkCollide = collide
	else
		self.checkCollide = false
	end
end

function Point.__add(v1, v2)
	return Point:new(v1.x + v2.x, v1.y + v2.y)
end

function Point.__sub(v1, v2)
	return Point:new(v1.x - v2.x, v1.y - v2.y)
end

function Point.__mul(v1, v2)
	if type(v1) == "number" then
		return Point:new(v1 * v2.x, v1 * v2.y)
	elseif type(v2 == "number") then
		return Point:new(v2 * v1.x, v2 * v1.y)
	else
		return Point:new(v1.x * v2.x, v1.y * v2.y)
	end
end

function Point.__div(v1, v2)
	if type(v1) == "number" then
		return Point:new(v1 / v2.x, v1 / v2.y)
	elseif type(v2) == "number" then
		return Point:new(v2 / v1.x, v2 / v1.y)
	else
		return Point:new(v1.x / v2.x, v1.y / v2.y)
	end
end

function Point.__unm(v1)
	return Point:new(-v1.x, -v1.y)
end

function Point.__eq(v1, v2)
	return v1.x == v2.x and v1.y == v2.y
end

function Point.__lt(v1, v2)
	return v1.x < v2.x and v1.y < v2.y
end

function Point.__le(v1, v2)
	return v1.x <= v2.x and v1.y <= v2.y
end

function Point:copy()
	return Point:new(self.x, self.y, self.c:copy())
end

function Point:dot(v)
	return self.x * v.x + self.y * v.y
end

function Point:draw()
	if self.checkCollide then
		if self.img == nil then
			EasyLD.graphics:point(self, self.c)
		else
			if self.imgType == "center" then
				local zW = EasyLD.vector:new(1, 0)
				local zH = EasyLD.vector:new(0, 1)
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
end

function Point:translate(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Point:moveTo(x, y)
	self.x = x
	self.y = y
end

function Point:rotate(angle, ox, oy)
	local cos, sin = math.cos(angle), math.sin(angle)
	local mat = EasyLD.matrix:newRotation(angle)
	local v = EasyLD.vector:new(self.x - ox, self.y - oy)
	v = mat * v

	self.x = v.x + ox
	self.y = v.y + oy
	self.angle = self.angle + angle
end

function Point:get()
	return self.x, self.y
end

--EasyLD.collide functions
function Point:collide(area)
	return area:collidePoint(self) and self.checkCollide
end

function Point:collideArea(area)
	return area:collidePoint(self) and self.checkCollide
end

function Point:collidePolygon(poly)
	return EasyLD.collide:Polygon_point(poly, self) and self.checkCollide
end

function Point:collideBox(b)
	if b.angle == 0 then
		return EasyLD.collide:AABB_point(b, self) and self.checkCollide
	else
		return EasyLD.collide:OBB_point(b, self) and self.checkCollide
	end
end

function Point:collideCircle(c)
	return EasyLD.collide:Circle_point(c, self) and self.checkCollide
end

function Point:collideSegment(s)
	return EasyLD.collide:Segment_point(s, self) and self.checkCollide
end

function Point:collidePoint(p)
	return p.x == self.x and p.y == self.y and self.checkCollide
end

return Point