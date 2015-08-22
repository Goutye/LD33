local class = require 'EasyLD.lib.middleclass'

local Shape = require 'EasyLD.Shape'
local Vector = require 'EasyLD.Vector'
local Area = class('Area', Shape)

function Area:initialize(obj, ox, oy, display)
	self.forms = {}
	if not obj:isInstanceOf(Shape) then
		print("Bad using of Area : Obj is not a shape")
	end
	table.insert(self.forms, obj)

	self.x = obj.x
	self.y = obj.y
	self.ox = ox or obj.x
	self.oy = oy or obj.y
	self.angle = 0

	self.display = display or true
	self.follower = obj
end

function Area:attach(obj)
	if obj:isInstanceOf(Shape) then
		table.insert(self.forms, obj)
	end
end

function Area:detach(obj)
	table.remove(self.forms, obj)
end

function Area:follow(obj)
	self.follower = obj
	obj.isFollowed = true
end

function Area:copy()
	local a = Area:new(self.forms[1]:copy(), self.ox, self.oy)

	for i = 2, #self.forms do
		table.insert(a.forms, self.forms[i]:copy())
	end

	a.x = self.x
	a.y = self.y
	a.follower = self.follower
	return a
end

function Area:moveTo(x, y)
	local dx, dy = x - self.x, y - self.y

	self:translate(dx, dy)
end

function Area:move(dx, dy, mode)
	self:translate(dx, dy, mode)
end

function Area:translate(dx, dy, mode)
	local vx, vy

	if mode == "relative" then
		local cos, sin = math.cos(self.angle), math.sin(self.angle)
		vx = Vector:new(cos, sin)
		vy = Vector:new(-sin, cos)
	else
		vx = Vector:new(1, 0)
		vy = Vector:new(0, 1)
	end
		
	vx = dx * vx
	vy = dy * vy

	for _,o in ipairs(self.forms) do
		o:translate(vx.x + vy.x, vx.y + vy.y)
	end
	
	self.x = self.forms[1].x
	self.y = self.forms[1].y
end

function Area:rotate(angle, ox, oy)
	if ox ~= nil and oy ~= nil then
		
	elseif self.follower ~= nil and self.follower:isInstanceOf(Shape) then
		ox = self.follower.x
		oy = self.follower.y
	else
		ox = self.ox
		oy = self.oy
	end
	for _,o in ipairs(self.forms) do
		o:rotate(angle, ox, oy)
	end

	self.x = self.forms[1].x
	self.y = self.forms[1].y
	self.angle = self.angle + angle
end

function Area:rotateTo(angle, ox, oy)
	self:rotate(angle-self.angle, ox, oy)
end

function Area:draw(reverse)
	if self.display then
		if reverse then
			for i = #self.forms, 1, -1 do
				self.forms[i]:draw()
			end
		else
			for _,o in ipairs(self.forms) do
				o:draw()
			end
		end
	end
end

--EasyLD.collide functions
function Area:collide(area)
	return area:collideArea(self)
end

function Area:collideArea(area)
	for _,f in ipairs(self.forms) do
		for _,f2 in ipairs(area.forms) do
			if f:collide(f2) then
				return true
			end
		end
	end

	return false
end

function Area:collidePolygon(poly)
	for _,f in ipairs(self.forms) do
		if f:collidePolygon(poly) then
			return true
		end
	end

	return false
end

function Area:collideBox(b, inside)
	for _,f in ipairs(self.forms) do
		if f:collideBox(b, inside) then
			return true
		end
	end

	return false
end

function Area:collideCircle(c)
	for _,f in ipairs(self.forms) do
		if f:collideCircle(c) then
			return true
		end
	end

	return false
end

function Area:collideSegment(s)
	for _,f in ipairs(self.forms) do
		if f:collideSegment(s) then
			return true
		end
	end

	return false
end

function Area:collidePoint(p)
	for _,f in ipairs(self.forms) do
		if f:collidePoint(p) then
			return true
		end
	end

	return false
end



return Area