local Collide = {}

local Vector = require 'EasyLD.Vector'
local Matrix = require 'EasyLD.Matrix'
local Point = require 'EasyLD.Point'
local Box = require 'EasyLD.Box'
local Circle = require 'EasyLD.Circle'

local _overlaps1Way = function(b, bAxis, bOrigin)
	for a = 1, #bAxis do
		local t = b.p[1]:dot(bAxis[a])
		local tMin, tMax = t, t

		for i = 2, #b.p do
			t = b.p[i]:dot(bAxis[a])

			if t < tMin then
				tMin = t
			elseif t > tMax then
				tMax = t
			end
		end

		if (tMin > 1+bOrigin[a]) or (tMax < bOrigin[a]) then
			return false
		end
	end

	return true
end

local _overlaps1WaySeg = function(b, bAxis, bOrigin, bBorder)
	for a = 1, #bAxis do
		local t = Point:projDot(bOrigin[a], bAxis[a], b.p[1])
		local tMin, tMax = t, t

		for i = 2, #b.p do
			t = Point:projDot(bOrigin[a], bAxis[a], b.p[i])

			if t < tMin then
				tMin = t
			elseif t > tMax then
				tMax = t
			end
		end

		if (tMin > bBorder) or (tMax < 0) then
			return false
		end
	end

	return true
end

local _overlaps1WayPoly = function(b, bAxis, bOrigin, b2)
	for a = 1, #bAxis do
		local t = Point:projDot(bOrigin, bAxis[a], b.p[1])
		local t2 = Point:projDot(bOrigin, bAxis[a], b2.p[1])
		local tMin, tMax = t, t
		local tMinB, tMaxB = t2, t2

		for i = 2, #b.p do
			t = Point:projDot(bOrigin, bAxis[a], b.p[i])

			if t < tMin then
				tMin = t
			elseif t > tMax then
				tMax = t
			end
		end

		for i = 2,#b2.p do
			t2 = Point:projDot(bOrigin, bAxis[a], b2.p[i])
			if t2 < tMinB then
				tMinB = t2
			elseif t2 > tMaxB then
				tMaxB = t2
			end
		end

		if not(tMaxB >= tMin and tMinB <= tMax) then
			return false
		end
	end

	return true
end

local _overlaps1WayCircle = function(b, bAxis, bOrigin, b2)
	for a = 1, #bAxis do
		local t = Point:projDot(bOrigin, bAxis[a], b.p[1])
		local tMin, tMax = t, t


		for i = 2, #b.p do
			t = Point:projDot(bOrigin, bAxis[a], b.p[i])

			if t < tMin then
				tMin = t
			elseif t > tMax then
				tMax = t
			end
		end

		b2.p = {}
		v = bAxis[a]:copy()
		v:normalize()
		v = v * b2.r
		b2.p[1] = b2.pos - v
		b2.p[2] = b2.pos + v

		local t2 = Point:projDot(bOrigin, bAxis[a], b2.p[1])
		local tMinB, tMaxB = t2, t2

		for i = 2,#b2.p do
			t2 = Point:projDot(bOrigin, bAxis[a], b2.p[i])
			if t2 < tMinB then
				tMinB = t2
			elseif t2 > tMaxB then
				tMaxB = t2
			end
		end

		if not(tMaxB >= tMin and tMinB <= tMax) then
			return false
		end
	end

	return true
end

function Collide:Polygon_polygon(poly1, poly2)
	seg1Axis = {}
	seg2Axis = {}

	for i = 1,#poly1.p do
		if i == #poly1.p then
			v = Vector:of(poly1.p[i], poly1.p[1])
		else
			v = Vector:of(poly1.p[i], poly1.p[i+1])
		end
		table.insert(seg1Axis, v:normal())
	end

	for i = 1,#poly2.p do
		if i == #poly2.p then
			v = Vector:of(poly2.p[i], poly2.p[1])
		else
			v = Vector:of(poly2.p[i], poly2.p[i+1])
		end
		table.insert(seg2Axis, v:normal())
	end

	seg1Origin = poly1.p[1]
	seg2Origin = poly2.p[1]

	return _overlaps1WayPoly(poly1, seg2Axis, seg2Origin, poly2) and _overlaps1WayPoly(poly2, seg1Axis, seg1Origin, poly1)
end

function Collide:Polygon_OBB(poly1, OBB)
	seg1Axis = {}
	seg2Axis = {}
	local poly2 = OBB

	for i = 1,#poly1.p do
		if i == #poly1.p then
			v = Vector:of(poly1.p[i], poly1.p[1])
		else
			v = Vector:of(poly1.p[i], poly1.p[i+1])
		end
		table.insert(seg1Axis, v:normal())
	end

	for i = 1,#poly2.p do
		if i == #poly2.p then
			v = Vector:of(poly2.p[i], poly2.p[1])
		else
			v = Vector:of(poly2.p[i], poly2.p[i+1])
		end
		table.insert(seg2Axis, v:normal())
	end

	seg1Origin = poly1.p[1]
	seg2Origin = poly2.p[1]

	return _overlaps1WayPoly(poly1, seg2Axis, seg2Origin, poly2) and _overlaps1WayPoly(poly2, seg1Axis, seg1Origin, poly1)
end

function Collide:Polygon_circle(poly1, circle)
	seg1Axis = {}
	seg2Axis = {}
	local c = {pos = Point:new(circle.x, circle.y), r = circle.r}
	local pos = c.pos

	for i = 1,#poly1.p do
		if i == #poly1.p then
			v = Vector:of(poly1.p[i], poly1.p[1])
		else
			v = Vector:of(poly1.p[i], poly1.p[i+1])
		end
		table.insert(seg1Axis, v:normal())
	end
	
	for i = 1,#poly1.p do
		v = Vector:of(pos, poly1.p[i])
		table.insert(seg2Axis, v)
	end

	seg1Origin = poly1.p[1]
	seg2Origin = c.pos

	return _overlaps1WayCircle(poly1, seg2Axis, seg2Origin, c) and _overlaps1WayCircle(poly1, seg1Axis, seg1Origin, c)
end

function Collide:Polygon_segment(poly, seg)
	seg1Axis = {}
	seg2Axis = {}
	local s1 = {p = {seg.p1, seg.p2}}

	local v = Vector:of(s1.p[1], s1.p[2])
	table.insert(seg1Axis, v:normal())

	for i = 1,#poly.p do
		if i == #poly.p then
			v = Vector:of(poly.p[i], poly.p[1])
		else
			v = Vector:of(poly.p[i], poly.p[i+1])
		end
		table.insert(seg2Axis, v:normal())
	end

	seg1Origin = s1.p[1]
	seg2Origin = poly.p[1]

	return _overlaps1WayPoly(s1, seg2Axis, seg2Origin, poly) and _overlaps1WayPoly(poly, seg1Axis, seg1Origin, s1)
end

function Collide:Polygon_point(poly1, point)
	seg1Axis = {}

	for i = 1,#poly1.p do
		if i == #poly1.p then
			v = Vector:of(poly1.p[i], poly1.p[1])
		else
			v = Vector:of(poly1.p[i], poly1.p[i+1])
		end
		table.insert(seg1Axis, v:normal())
	end

	seg1Origin = poly1.p[1]

	return _overlaps1WayPoly(poly1, seg1Axis, seg1Origin, {p = {point}})
end

function Collide:OBB_OBB(b1, b2)
	b1Axis = {}
	b2Axis = {}
	b1Origin = {}
	b2Origin = {}

	table.insert(b1Axis, Vector:of(b1.p[1], b1.p[2]))
	table.insert(b1Axis, Vector:of(b1.p[1], b1.p[4]))
	table.insert(b2Axis, Vector:of(b2.p[1], b2.p[2]))
	table.insert(b2Axis, Vector:of(b2.p[1], b2.p[4]))

	for i = 1, 2 do
		b1Axis[i] = b1Axis[i] / b1Axis[i]:squaredLength()
		b2Axis[i] = b2Axis[i] / b2Axis[i]:squaredLength()
		b1Origin[i] = b1.p[1]:dot(b1Axis[i])
		b2Origin[i] = b2.p[1]:dot(b2Axis[i])
	end

	return _overlaps1Way(b1, b2Axis, b2Origin) and _overlaps1Way(b2, b1Axis, b1Origin)
end

function Collide:OBB_circle(box, circle)
	local v1 = Vector:of(box.p[1], box.p[2])
	local v2 = Vector:of(box.p[1], box.p[4])
	v1:normalize()
	v2:normalize()

	local m = Matrix:newBase(v1, v2):invert()

	local circleP = Point:new(circle.x, circle.y)
	circleP = m * circleP

	local boxP = box.p[1]:copy()
	boxP = m * boxP

	local boxR = Box:new(boxP.x, boxP.y, box.w, box.h)
	local circleR = Circle:new(circleP.x, circleP.y, circle.r)

	return Collide:AABB_circle(boxR, circleR, false)
end

function Collide:OBB_segment(b, seg)
	seg1Axis = {}
	seg2Axis = {}
	seg1Origin = {}
	seg2Origin = {}
	seg1Border = {}
	seg2Border = {}
	local s1 = {p = {seg.p1, seg.p2}}

	local v = Vector:of(s1.p[1], s1.p[2])
	table.insert(seg1Axis, v:normal())
	table.insert(seg2Axis, Vector:of(b.p[1], b.p[2]))
	table.insert(seg2Axis, Vector:of(b.p[1], b.p[4]))

	
	seg1Origin[1] = s1.p[1]
	seg1Border = 0
	seg2Origin[1] = b.p[1]
	seg2Origin[2] = b.p[1]
	seg2Border = 1

	return _overlaps1WaySeg(s1, seg2Axis, seg2Origin, seg2Border) and _overlaps1WaySeg(b, seg1Axis, seg1Origin, seg1Border)
end

function Collide:OBB_point(box, point)
	b1Axis = {}
	b1Origin = {}

	table.insert(b1Axis, Vector:of(box.p[1], box.p[2]))
	table.insert(b1Axis, Vector:of(box.p[1], box.p[4]))

	for i = 1, 2 do
		b1Axis[i] = b1Axis[i] / b1Axis[i]:squaredLength()
		b1Origin[i] = box.p[1]:dot(b1Axis[i])
	end

	for a = 1, 2 do
		local t = point:dot(b1Axis[a])
		local tMin, tMax = t, t

		if (tMin > 1 + b1Origin[a]) or (tMax < b1Origin[a]) then
			return false
		end
	end

	return true
end

function Collide:Segment_segment(seg1, seg2)
	seg1Axis = {}
	seg2Axis = {}
	seg1Origin = {}
	seg2Origin = {}
	local s1 = {p = {seg1.p1, seg1.p2}}
	local s2 = {p = {seg2.p1, seg2.p2}}

	local v = Vector:of(s1.p[1], s1.p[2])
	table.insert(seg1Axis, v:normal())
	v = Vector:of(s2.p[1], s2.p[2])
	table.insert(seg2Axis, v:normal())

	for i = 1, #seg1Axis do
		seg1Origin[i] = s1.p[1]
		seg2Origin[i] = s2.p[1]
	end

	return _overlaps1WaySeg(s1, seg2Axis, seg2Origin, 0) and _overlaps1WaySeg(s2, seg1Axis, seg1Origin, 0)
end

function Collide:Segment_point(seg, point)
	local p, dot = Point:proj(seg.p1, seg.p2, point)

	if dot < 0 or dot > 1 then
		return false
	else
		v2 = Vector:of(p, point)

		return v2:squaredLength() <= 1
	end
end

function Collide:AABB_circle(box, circle, boolReturnPos)
	local pos = {}
	pos.x = circle.x
	pos.y = circle.y

	if pos.x > box.x + box.w - 1 then
		pos.x = box.x + box.w - 1
	elseif pos.x < box.x then
		pos.x = box.x
	end
	if pos.y > box.y + box.h - 1 then
		pos.y = box.y + box.h - 1
	elseif pos.y < box.y then
		pos.y = box.y
	end

	local collision = Collide:Circle_point(circle, pos)

	if boolReturnPos then
		return collision, pos
	else
		return collision
	end
end

function Collide:Circle_inAABB(circle, box)
	return circle.x - circle.r >= box.x
		and circle.y - circle.r >= box.y
		and circle.x + circle.r <= box.x + box.w-1
		and circle.y + circle.r <= box.y + box.h-1
end

function Collide:AABB_inCircle(box, circle, boolReturnPos)
	local pos = {}
	
	local collision = true
	local pos = {}
	pos[0] = {x = box.x, y = box.y}
	pos[1] = {x = box.x + box.w-1, y = box.y}
	pos[2] = {x = box.x, y = box.y + box.h-1}
	pos[3] = {x = box.x + box.w, y = box.y + box.h}

	for i = 0, 3 do
		collision = collision and Collide:Circle_point(circle, pos[i])
	end

	if boolReturnPos then
		return collision, pos
	else
		return collision
	end
end

function Collide:AABB_point(box, point)
	return point.x >= box.x and point.x <= box.x + box.w - 1 and 
			point.y >= box.y and point.y <= box.y + box.h - 1 
end

function Collide:AABB_AABB(box1, box2)
	return	box2.x				<= box1.x + box1.w -1
		and box2.x + box2.w -1	>= box1.x 
		and box2.y 				<= box1.y + box1.h -1
		and box2.y + box2.h -1	>= box1.y
end

function Collide:AABB_inAABB(box1, box2)
	return box1.x >= box2.x
		and box1.y >= box2.y
		and box1.x + box1.w <= box2.x + box2.w
		and box1.y + box1.h <= box2.x + box2.h
end

function Collide:Circle_point(circle, point)
	local v = Vector:of(circle, point)
	return v:length() <= circle.r
end

function Collide:Circle_segment(circle, seg)
	local pos = Point:new(circle.x, circle.y)
	local v = Vector:of(seg.p1, seg.p2)
	local v2 = Vector:of(seg.p1, pos)
	local norm = v:length()
	local dotV_V2 = v:dot(v2) / (norm * norm)

	if dotV_V2 <= 0 then
		return v2:squaredLength() <= circle.r * circle.r
	elseif dotV_V2 >= 1 then
		v2 = Vector:of(seg.p2, pos)
		return v2:squaredLength() <= circle.r * circle.r
	else
		local proj = seg.p1 + (v * dotV_V2)
		v2 = Vector:of(proj, pos)

		return v2:squaredLength() <= circle.r * circle.r
	end
end

function Collide:Circle_circle(circle, circle2)
	return Vector:of(circle, circle2):length() < circle.r + circle2.r
end


function Collide:isInAreaLine(pos1, dir, pos2)
	c = - pos1.x * dir.x - pos1.y * dir.y
	return pos2.x * dir.x + pos2.y * dir.y + c >= 0
end


return Collide