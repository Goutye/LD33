local class = require 'EasyLD.lib.middleclass'

local Vector = class('Vector')

function Vector.static:of(pos1, pos2)
	return Vector:new(pos2.x - pos1.x, pos2.y - pos1.y)
end

function Vector:initialize(x, y)
	self.x = x
	self.y = y
end

function Vector.__add(v1, v2)
	return Vector:new(v1.x + v2.x, v1.y + v2.y)
end

function Vector.__sub(v1, v2)
	return Vector:new(v1.x - v2.x, v1.y - v2.y)
end

function Vector.__mul(v1, v2)
	if type(v1) == "number" then
		return Vector:new(v1 * v2.x, v1 * v2.y)
	elseif type(v2) == "number" then
		return Vector:new(v2 * v1.x, v2 * v1.y)
	else
		return Vector:new(v1.x * v2.x, v1.y * v2.y)
	end
end

function Vector.__div(v1, v2)
	if type(v1) == "number" then
		return Vector:new(v1 / v2.x, v1 / v2.y)
	elseif type(v2) == "number" then
		return Vector:new(v1.x / v2, v1.y / v2)
	else
		return Vector:new(v1.x / v2.x, v1.y / v2.y)
	end
end

function Vector.__unm(v1)
	return Vector:new(-v1.x, -v1.y)
end

function Vector.__eq(v1, v2)
	return v1.x == v2.x and v1.y == v2.y
end

function Vector.__lt(v1, v2)
	return v1.x < v2.x and v1.y < v2.y
end

function Vector.__le(v1, v2)
	return v1.x <= v2.x and v1.y <= v2.y
end

function Vector:normalize()
	local l = self:length()
	self.x = self.x / l
	self.y = self.y / l
end

function Vector:length()
	return math.sqrt(self:squaredLength())
end

function Vector:squaredLength()
	return self.x * self.x + self.y * self.y
end

function Vector:dot(v)
	if v:isInstanceOf(Vector) then
		return self.x * v.x + self.y * v.y
	end
end

function Vector:rotate(angle)
	local mat = EasyLD.matrix:newRotation(angle)
	local v = mat * self
	self.x = v.x
	self.y = v.y
end

function Vector:copy()
	return Vector:new(self.x, self.y)
end

function Vector:normal()
	return Vector:new(-self.y, self.x)
end

function Vector:getAngle()
	local v = self:copy()
	v:normalize()
	local angle = math.acos(v.y)

	if v.x > 0 then
		angle = -angle
	end

	angle = angle + math.pi/2

	if angle < 0 then
		angle = angle + math.pi*2
	end

	return angle
end

return Vector