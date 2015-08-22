local class = require 'EasyLD.lib.middleclass'

local Vector = require 'EasyLD.Vector'
local Point = require 'EasyLD.Point'

local Matrix = class('Matrix')

function Matrix.static:newRotation(angle)
	local m = Matrix:new(2, 2)
	local cos, sin = math.cos(angle), math.sin(angle)

	m.d[0][0], m.d[0][1] = cos, -sin
	m.d[1][0], m.d[1][1] = sin, cos

	return m
end

function Matrix.static:newBase(v1, v2)
	local m = Matrix:new(2, 2)
	
	m.d[0][0], m.d[0][1] = v1.x, v2.x
	m.d[1][0], m.d[1][1] = v1.y, v2.y

	return m
end

function Matrix:initialize(w, h)
	self.w = w
	self.h = h
	self.d = {}

	for i = 0, w - 1 do
		self.d[i] = {}

		for j = 0, h - 1 do
			self.d[i][j] = 0
		end
	end
end

function Matrix.__mul(m, v)
	if m:isInstanceOf(Matrix) and type(v) == "number" then
		local s = Matrix:new(m.w, m.h)
		for i = 0, s.w - 1 do
			for j = 0, s.h - 1 do
				s.d[i][j] = m.d[i][j] * v
			end
		end

		return s
	elseif m:isInstanceOf(Matrix) and (v:isInstanceOf(Vector) or v:isInstanceOf(Point)) then
		return Vector:new(m.d[0][0] * v.x + m.d[0][1] * v.y, m.d[1][0] * v.x + m.d[1][1] * v.y)
	elseif m:isInstanceOf(Matrix) and v:isInstanceOf(Matrix) and m.w == v.h then
		local s = Matrix:new(v.w, m.h)

		for i = 0, s.w - 1 do
			for j = 0, s.h - 1 do
				for k = 0, m.w - 1 do
					s.d[i][j] = s.d[i][j] + m.d[i][k] * v.d[k][j]
				end
			end
		end

		return s
	end
end

function Matrix:det()
	if self.w == 2 and self.h == 2 then
		return self.d[0][0] * self.d[1][1] - self.d[0][1] * self.d[1][0]
	elseif self.w == 3 and self.h == 3 then
		return self.d[0][0] * self:subMatrix(0, 0):det()
				- self.d[1][0] * self:subMatrix(1, 0):det()
				+ self.d[2][0] * self:subMatrix(2, 0):det()
	end
end

function Matrix:subMatrix(x, y)
	local m = Matrix:new(self.w - 1, self.h - 1)
	local k, l = 0 , 0

	for i = 0, self.w - 1 do
		if i ~= x then
			for j = 0, self.h - 1 do
				if j ~= y then
					m.d[k][l] = self.d[i][j] 
					l = l + 1
				end
			end
			k = k + 1
		end
		l = 0
	end

	return m
end

function Matrix:log()
	for i = 0, self.w - 1 do
		local s = ""
		for j = 0, self. w - 1 do
			s = s .. self.d[i][j] .. ", "
		end
		print(s)
	end
end

function Matrix:invert()
	local det

	if self.w == 2 and self.h == 2 then
		det = self:det()

		if det == 0 then
			print("Matrix not invertible")
			return
		end

		local m = Matrix:new(2, 2)
		m.d[0][0] = self.d[1][1]
		m.d[1][1] = self.d[0][0]
		m.d[0][1] = self.d[0][1] * -1
		m.d[1][0] = self.d[1][0] * -1

		return m * (1/det)
	elseif self.w == 3 and self.h == 3 then
		det = self:det()

		if det == 0 then
			print("Matrix not invertible")
			return
		end

		print("NOT IMPLEMENTED")
	end
end

return Matrix