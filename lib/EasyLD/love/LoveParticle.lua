local class = require 'EasyLD.lib.middleclass'

local MainParticle = require 'EasyLD.Particle'
local Particle = class('Particle', MainParticle)

function Particle:initialize(obj, img, x, y, size)
	self.follower = obj
	self.size = size or 512
	if img then
		if type(img) ~= "string" then
			self.p = love.graphics.newParticleSystem(img.s, size)
		else
			self.p = love.graphics.newParticleSystem(love.graphics.newImage(img), size)
		end
	end
	self.sizeP = 64
	self.rate = 1
	self.pause = true

	self.angleSpeed = 0
	self.angle = 0
	self.spread = 0
	self.duration = 0
end

function Particle:start()
	--self.p:start()
	self.pause = false
	self:setEmissionRate(self.rate)
	if self.emissionTable then
		self:startEmissionEasing()
	end
	if self.tableEmit then
		self:startTimedEmit()
	end
end

function Particle:emit(nb)
	local n = self.p:getCount()
	if n + nb > self.size then
		self.size = self.size * 2
		self.p:setBufferSize(self.size)
	end
	self.p:emit(nb)
end

function Particle:stop()
	--self.p:stop()
	self:stopTimer()
	self:setEmissionRate(0)
	self.pause = true
end

function Particle:reset()
	self.p:reset()
end

function Particle:clone()
	local p = self.p:clone()
	local newSystem = Particle:new(self.follower:copy())
	newSystem.p = p
	newSystem.rate = self.rate
	newSystem.angle = self.angle
	newSystem.angleSpeed = self.angleSpeed
	newSystem.spread = self.spread
	return newSystem
end

function Particle:draw()
	love.graphics.draw(self.p)
end

function Particle:update(dt)
	self:moveTo(self.follower.x, self.follower.y)
	self.p:update(dt)
	self:setDirection(self.angle + self.angleSpeed * dt, self.spread)
	local nb = self.p:getCount()
	if nb > self.size * 0.95 then
		self.size = self.size *2
		self.p:setBufferSize(self.size)
	elseif nb < 0.475 * self.size and self.size > 512 then
		self.size = self.size / 2
		self.p:setBufferSize(self.size)
	end
end

function Particle:moveTo(x, y)
	self.p:moveTo(x, y)
end

function Particle:getPosition()
	return EasyLD.point:new(self.p:get_position())
end

function Particle:setDirection(angle, spread)
	self.angle = angle
	self.spread = spread
	self.p:setSpread(spread)
	self.p:setDirection(-angle)
end

function Particle:setOffset(x, y)
	self.p:setAreaSpread('uniform' , x, y)
end

function Particle:getOffset()
	local _,x,y = self.p:getAreaSpread()
	return EasyLD.point:new(x,y)
end

function Particle:setSizes(tab)
	local t = {}
	local dist = {1,1,1,1,1,1,1}
	for i,v in pairs(tab) do
		if i == 0 then
			t[1] = v / self.sizeP
		elseif i < 3/14 and math.abs(i-1/7) < dist[1] then
			t[2] = v / self.sizeP
			dist[1] = math.abs(i-1/7)
		elseif i < 5/14 and math.abs(i-2/7) < dist[2] then
			t[3] = v / self.sizeP
			dist[2] = math.abs(i-2/7)
		elseif i < 7/14 and math.abs(i-3/7) < dist[3] then
			t[4] = v / self.sizeP
			dist[3] = math.abs(i-3/7)
		elseif i < 9/14 and math.abs(i-4/7) < dist[4] then
			t[5] = v / self.sizeP
			dist[4] = math.abs(i-4/7)
		elseif i < 11/14 and math.abs(i-5/7) < dist[5] then
			t[6] = v / self.sizeP
			dist[5] = math.abs(i-5/7)
		elseif i < 13/14 and math.abs(i-6/7) < dist[6] then
			t[7] = v / self.sizeP
			dist[6] = math.abs(i-6/7)
		elseif math.abs(i - 1) < dist[7] then
			t[8] = v / self.sizeP
			dist[7] = math.abs(i-1)
		end
	end
	local prev, next = 0, 0
	for i=1,8 do
		if t[i] == nil then
			for j = i+1, 8 do
				if t[j] ~= nil then
					next = j
				end
			end
			if next < i then
				t[i] = t[prev]
			else
				local weight = 1/(i-prev) + 1/(next-i)
				t[i] = (t[prev] * 1/(i-prev) + t[next] * 1/(next-i))/weight
			end
		end
		prev = i
	end
	self.p:setSizes(unpack(t))
	self.t = t
end

function Particle:setColors(tab)
	local t = {}
	local dist = {1,1,1,1,1,1,1}
	for i,v in pairs(tab) do
		if i == 0 then
			t[1] = v
		elseif i < 3/14 and math.abs(i-1/7) < dist[1] then
			t[2] = v
			dist[1] = math.abs(i-1/7)
		elseif i < 5/14 and math.abs(i-2/7) < dist[2] then
			t[3] = v
			dist[2] = math.abs(i-2/7)
		elseif i < 7/14 and math.abs(i-3/7) < dist[3] then
			t[4] = v
			dist[3] = math.abs(i-3/7)
		elseif i < 9/14 and math.abs(i-4/7) < dist[4] then
			t[5] = v
			dist[4] = math.abs(i-4/7)
		elseif i < 11/14 and math.abs(i-5/7) < dist[5] then
			t[6] = v
			dist[5] = math.abs(i-5/7)
		elseif i < 13/14 and math.abs(i-6/7) < dist[6] then
			t[7] = v
			dist[6] = math.abs(i-6/7)
		elseif math.abs(i - 1) < dist[7] then
			t[8] = v
			dist[7] = math.abs(i-1)
		end
	end
	local prev, next = 0, 0
	for i=1,8 do
		if t[i] == nil then
			for j = i+1, 8 do
				if t[j] ~= nil then
					next = j
				end
			end
			if next < i then
				t[i] = t[prev]
			else
				local weight = 1/(i-prev) + 1/(next-i)
				t[i] = {}
				for i,v in ipairs({r,g,b,a}) do
					t[i][v] = (t[prev][v] * 1/(i-prev) + t[next][v] * 1/(next-i))/weight
				end
			end
		end
		prev = i
	end
	tab = {}
	for i,v in ipairs(t) do
		table.insert(tab, v.r)
		table.insert(tab, v.g)
		table.insert(tab, v.b)
		table.insert(tab, v.a)
	end
	self.p:setColors(unpack(tab))
end

function Particle:setTexture(img, x, y)
	if x == nil then
		self.p:setTexture(img.s)
	else
		local s = EasyLD.surface:new(64, 64)
		local old = s:drawOn()
		EasyLD.camera:push()
		EasyLD.camera:reset()
		img:drawPart(0, 0, x, y, 64, 64)
		self.surface = s
		old:drawOn()
		EasyLD.camera:pop()
		EasyLD.actualize()

		self.p:setTexture(s)
	end
end

function Particle:setEmissionRate(nb, ease)
	if not self.pause then
		if type(nb) == "number" then
			self.p:setEmissionRate(math.floor(nb))
		else
			self:setEmissionRateEasing(nb, ease)
		end
	end
	if type(nb) == "number" and nb > 0 then
		self.rate = math.floor(nb)
	elseif type(nb) == "table" then
		self:setEmissionRateEasing(nb, ease)
		self.p:setEmissionRate(0)
	end
end

function Particle:getEmissionRate()
	return self.p:getEmissionRate()
end

function Particle:setLifeTime(min, max)
	self.p:setParticleLifetime(min, max)
end

function Particle:getLifeTime()
	return self.p:getParticleLifetime()
end

function Particle:setInitialVelocity(nb)
	self.p:setSpeed(nb)
end

function Particle:setInitialAcceleration(nb)
	self.p:setRadialAcceleration(nb)
end

function Particle:setRotation(min, max)
	self.p:setRotation(min, max)
end

function Particle:setSpinEmitter(angleSpeed)
	self.angleSpeed = angleSpeed
	self.spin = angleSpeed ~= 0

	if self.relative and self.spin then
		self.p:setSpin(-self.angleSpeed)
	end
end

function Particle:setRelativeRotation()
	self.p:setRelativeRotation(true)
	self.relative = true

	if self.relative and self.spin then
		self.p:setSpin(-self.angleSpeed)
	end
end

return Particle