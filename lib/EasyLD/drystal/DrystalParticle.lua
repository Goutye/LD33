local class = require 'EasyLD.lib.middleclass'

local MainParticle = require 'EasyLD.Particle'
local Particle = class('Particle', MainParticle)

function Particle:initialize(obj, img, x, y, size)
	self.p = drystal.new_system(obj.x, obj.y, size)
	self.follower = obj
	self.size = size or 256
	self.img = img
	self.rotation = {min = 0, max = 0}
	self.surfaceRotated = EasyLD.surface:new(64,64)
	self.surfaceRotated:setFilter("nearest")
	if img then
		self:setTexture(img, x, y)
	end
	self.angleSpeed = 0
	self.angle = 0
	self.spread = 0
	self.mode = 64
	self.sizes = {}
	self.duration = 0

	self.system = {}
	self.timer = {}
end

function Particle:start()
	self.p:start()
	if self.emissionTable then
		self:startEmissionEasing()
	end
	if self.tableEmit then
		self:startTimedEmit()
	end
	for i,v in ipairs(self.system) do
		v:start()
	end
end

function Particle:emit(nb)
	local emitPerSystem = math.floor(nb / (1 + #self.system))
	self.p:emit(emitPerSystem)
	for i,v in ipairs(self.system) do
		v.p:emit(emitPerSystem)
	end
end

function Particle:stop()
	self:stopTimer()
	self.p:stop()
	for i, v in ipairs(self.system) do
		v.p:stop()
	end
end

function Particle:reset()
	self.p:reset()
end

function Particle:clone()
	local p = self.p:clone()
	local newSystem = Particle:new(self.follower:copy())
	newSystem.p = p
	newSystem.alpha = self.alpha
	newSystem.angle = self.angle
	newSystem.angleSpeed = self.angleSpeed
	newSystem.spread = self.spread
	newSystem.img = self.img
	newSystem.relative = self.relative
	newSystem.spin = self.spin
	newSystem.sizes = {}
	for i,v in pairs(self.sizes) do
		newSystem.sizes[i] = v
	end
	newSystem.rotation = {min = self.rotation.min, max = self.rotation.max}
	newSystem.mode = self.mode
	return newSystem
end

function Particle:draw()
	drystal.set_alpha(self.alpha)
	self.p:draw(0, 0)
	for i,v in ipairs(self.system) do
		v:draw()
	end
end

function Particle:update(dt)
	self:moveTo(self.follower.x, self.follower.y)
	self.p:update(dt)
	self:setDirection(self.angle + self.angleSpeed * dt, self.spread)
	if self.relative and self.spin then
		self:setRotation(-self.angle, nil, 1)
	end
	for i,v in ipairs(self.system) do
		v:update(dt)
	end
end

function Particle:moveTo(x, y)
	self.p:set_position(x, y)
end

function Particle:getPosition()
	return EasyLD.point:new(self.p:get_position())
end

function Particle:setDirection(angle, spread)
	self.angle = angle
	self.spread = spread
	spread = spread/2
	angle = -angle
	self.p:set_direction(angle - spread, angle + spread)
end

function Particle:setOffset(x, y)
	self.p:set_offset(x, y)
end

function Particle:getOffset()
	return EasyLD.point:new(self.p:get_offset())
end

function Particle:setSizes(table)
	if self.mode == 32 and not self.resizeOk then
		self.resizeOk = true
		for i,v in pairs(table) do
			table[i] = v * 2
		end
	end
	self.sizes = table
	self.p:set_sizes(table)
end

function Particle:setColors(table)
	local t = {}
	local a = 0
	local c = 0
	for i,v in pairs(table) do
		t[i] = drystal.new_color("rgb", v.r, v.g, v.b)
		if v.a > 0 then
			a = a + v.a
			c = c + 1
		end
	end
	self.p:set_colors(t)
	self.alpha = a/c
end

function Particle:setTexture(img, x, y)
	if type(img) ~= "string" then
		self.img = img
		if self.mode == 32 then
			self.surfaceRotated:clear()
			self.surfaceRotated:drawOn()
			img.s:draw_from()
			EasyLD.camera:push()
			EasyLD.camera:reset()
			local angle = math.random() * (self.rotation.max - self.rotation.min) + self.rotation.min
			drystal.draw_sprite({x=0,y=0,w=64,h=64},16,16,{angle = angle, wfactor = 0.5, hfactor = 0.5})
			self.p:set_texture(self.surfaceRotated.s, 0, 0)
			EasyLD.camera:pop()
			EasyLD.surface:drawOnScreen()
		else
			self.p:set_texture(img.s, 0, 0)
		end
	else
		local surface = drystal.load_surface(img)
		local surface2 = EasyLD.surface:new(64,64)
		surface2:drawOn()
		surface:draw_from()
		EasyLD.camera:push()
		EasyLD.camera:reset()
		drystal.draw_sprite_simple({x=x or 0, y=y or 0, w=64, h=64}, 0, 0)
		EasyLD.camera:pop()
		EasyLD.surface:drawOnScreen()
		self.img = surface2
		self:setTexture(surface2)
	end
end

function Particle:setEmissionRate(nb, easing)
	if type(nb) == "number" then
		local emissionPerSystem = nb / (1 + #self.system)
		self.p:set_emission_rate(math.floor(emissionPerSystem))
		for i,v in ipairs(self.system) do
			v:setEmissionRate(math.floor(emissionPerSystem))
		end
		self.rate = math.floor(nb)
	else
		self:setEmissionRateEasing(nb, easing)
	end
end

function Particle:getEmissionRate()
	return self.p:get_emission_rate()
end

function Particle:setLifeTime(min, max)
	self.p:set_lifetime(min, max)
end

function Particle:getLifeTime()
	return self.p:get_lifetime()
end

function Particle:setInitialVelocity(nb)
	self.p:set_initial_velocity(nb)
end

function Particle:setInitialAcceleration(nb)
	self.p:set_initial_acceleration(nb)
end

function Particle:setRotation(min, max, approx)
	self.mode = 32
	self:setSizes(self.sizes)
	approx = approx or 4
	self.rotation = {min = min, max = max or min}
	self:setTexture(self.img)
	local time = 1/self:getEmissionRate()
	self:setEmissionRate(self:getEmissionRate()/approx)

	for i = 1, approx-1 do
		table.insert(self.system, self:clone())
		self.system[i]:follow(self.follower)
		self.system[i]:setTexture(self.img)

		self.timer[i] = EasyLD.timer.after(time*i, function () self.system[i]:start() end)
	end
end

function Particle:setSpinEmitter(angleSpeed)
	self.angleSpeed = angleSpeed
	self.spin = angleSpeed ~= 0
end

function Particle:setRelativeRotation(approx)
	if #self.system == 0 then
		self.relative = true
		approx = approx or math.ceil(self.spread/(math.pi/8))
		local stepSpread = self.spread/approx
		local start = self.angle - self.spread/2 + stepSpread/2
		local time = 1/self:getEmissionRate()
		self:setEmissionRate(self:getEmissionRate()/approx)
		
		local alea = {}

		for i = 1, approx-1 do
			table.insert(self.system, self:clone())
			self.system[i]:follow(self.follower)
			self.system[i]:setDirection(start, stepSpread)

			if i == 1 then
				self.system[i]:setRotation(-start + stepSpread/2, nil, 1)
			else
				self.system[i]:setRotation(-start, nil, 1)
			end

			start = start + stepSpread
			local rand = math.random(1, approx-1)
			while alea[rand] do
				rand = math.random(1, approx-1)
			end
			self.timer[i] = EasyLD.timer.after(time*rand, function () self.system[i]:start() end)
		end

		self:setDirection(start, stepSpread)
		self:setRotation(-start - stepSpread/2, nil, 1)
	end
end

return Particle