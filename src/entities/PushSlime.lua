local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local PushSlime = class('PushSlime', Entity)

function PushSlime:load()
	self.isPlayer = false
	self.power = 20
	self.distance = 150
	self.dmg = 5
	self.life = 10
	self.maxLife = 10

	self.timePush = 2
	self.timePushFull = 2

	self.pushPolygon = EasyLD.polygon:new("fill", EasyLD.color:new(255,0,0,200), self.pos:copy(), self.pos:copy(), self.pos:copy())

	self.PS = EasyLD.particles:new(self.pos, "assets/smoke.png")
	self.PS:setEmissionRate(200)
	self.PS:setLifeTime(0.5)
	self.PS:setInitialVelocity(200)
	self.PS:setInitialAcceleration(0)
	self.PS:setDirection(0, math.pi/2)
	self.PS:setColors({[0] = EasyLD.color:new(255,255,255,200),
						[1] = EasyLD.color:new(255,255,255,0)})
	self.PS:setSizes({[0] = 16,
						[1] = 48})
end

function PushSlime:update(dt, entities, map)
	local ACCELERATION = 1000

	self.acceleration = EasyLD.point:new(0, 0)

	if self.isPlayer then
		if EasyLD.keyboard:isDown("a") or EasyLD.keyboard:isDown("q") then
			self.acceleration.x = self.acceleration.x - ACCELERATION
		end
		if EasyLD.keyboard:isDown("w") or EasyLD.keyboard:isDown("z") then
			self.acceleration.y = self.acceleration.y - ACCELERATION
		end
		if EasyLD.keyboard:isDown("d") then
			self.acceleration.x = self.acceleration.x + ACCELERATION
		end
		if EasyLD.keyboard:isDown("s") then
			self.acceleration.y = self.acceleration.y + ACCELERATION
		end

		local vectorPush = EasyLD.vector:of(self.pos, DM:getMousePos())
		vectorPush:normalize()
		vectorPush = vectorPush * self.distance
		local vectorNormal = vectorPush:normal() * .5
		local p1 = self.pos + vectorPush
		local p2 = p1:copy()
		p1, p2 = p1 - vectorNormal, p2 + vectorNormal
		self.PS:setDirection(math.pi * 2 - vectorPush:getAngle(), math.pi/2)
		self.pushPolygon = EasyLD.polygon:new("fill", EasyLD.color:new(255,0,0,200), p1, p2, self.pos:copy())
		
		if EasyLD.mouse:isDown("l") and self.timePush > 0 then
			self:push(entities)
			self.timePush = self.timePush - dt
			if self.timePush <= 0 then
				self.isPushing = false
				self.PS:stop()
				self.timerPush = EasyLD.timer.after(self.timePushFull + self.timePush, function() self.timerPush, self.timePush = nil, self.timePushFull end)
			end
		else
			self.isPushing = false
			self.PS:stop()
		end
	else
		if self.timePush > 0 then
			if self.hero == nil then
				for _,e in ipairs(entities) do
					if e.level ~= nil then
						self.hero = e
						break
					end
				end
			end

			if self.hero ~= nil then
				local vectorPush = EasyLD.vector:of(self.pos, self.hero.pos)
				vectorPush:normalize()
				vectorPush = vectorPush * self.distance
				local vectorNormal = vectorPush:normal() * .5
				local p1 = self.pos + vectorPush
				local p2 = p1:copy()
				p1, p2 = p1 - vectorNormal, p2 + vectorNormal
				self.PS:setDirection(math.pi * 2 - vectorPush:getAngle(), math.pi/2)
				self.pushPolygon = EasyLD.polygon:new("fill", EasyLD.color:new(255,0,0,200), p1, p2, self.pos:copy())
			end

			if self.hero ~= nil and self.hero.collideArea:collide(self.pushPolygon) then
				self:push(entities)
				self.timePush = self.timePush - dt
				if self.timePush <= 0 then
					self.isPushing = false
					self.PS:stop()
					self.timerPush = EasyLD.timer.after(self.timePushFull + self.timePush, function() self.timerPush, self.timePush = nil, self.timePushFull end)
				end
			end
		else
			self.PS:stop()
		end
	end

	if map:collideHole(self.collideArea) then
		self:takeDmg(5)
	end

	self.PS.follower:moveTo(self.pos:get())
	self.PS:update(dt)
end

function PushSlime:push(entities)
	if not self.isPushing then
		self.PS:start()
		self.isPushing = true
	end
	for _,e in ipairs(entities) do
		if e.id ~= self.id and self.pushPolygon:collide(e.collideArea) then
			local dir = EasyLD.vector:of(self.pos, e.pos)
			dir:normalize() 
			e.speed = e.speed + (dir * self.power)
		end
	end
end

function PushSlime:onDeath()

end

function PushSlime:onCollide(entity)

end

function PushSlime:drawUI()
	local ratio = self.life/self.maxLife
	local r = self.collideArea.forms[1].r
	local lifeBox = EasyLD.box:new(self.pos.x - r, self.pos.y - 3*r/2, r * 2 * ratio , 2, EasyLD.color:new(255,0,0))
	lifeBox:draw()
end

function PushSlime:draw()
	self.PS:draw()
	if self.spriteAnimation ~= nil then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
	end

	if self.timePush > 0 then
		self.collideArea.forms[1].c = EasyLD.color:new(255,255,255)
		--self.pushPolygon:draw()
	else
		self.collideArea.forms[1].c = EasyLD.color:new(200,200,200)
	end

	--font:print(self.life .. "/"..self.maxLife, 16, EasyLD.box:new(self.pos.x, self.pos.y, 50, 20), nil, nil, EasyLD.color:new(0,0,255))
end

return PushSlime