local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local FireSlime = class('FireSlime', Entity)

function FireSlime:load()
	self.isPlayer = false
	self.power = 100
	self.dmg = 5
	self.life = 10
	self.maxLife = 10
	self.canAttack = true
	self.reloadTime = 1
	self.vectorFire = EasyLD.vector:new(0,0)
	self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos:copy())
end

function FireSlime:update(dt, entities, map)
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

		self.vectorFire = EasyLD.vector:of(self.pos, DM:getMousePos())
		self.vectorFire:normalize()
		self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos + (self.vectorFire * self.power), EasyLD.color:new(255,0,0))
		
		if EasyLD.mouse:isPressed("l") then
			self:fire(entities)
		end
	elseif self.canAttack then
		self.vectorFire = EasyLD.vector:of(self.pos, DM:getMousePos())
		self.vectorFire:normalize()
		self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos + (self.vectorFire * self.power), EasyLD.color:new(255,0,0))
		if self.hero == nil then
			for _,e in ipairs(entities) do
				if e.level ~= nil then
					self.hero = e
					break
				end
			end
		end

		if self.hero ~= nil and self.hero.collideArea:collide(self.fireSegment) then
			self.canAttack = false
			self.timerAttack = EasyLD.timer.after(self.reloadTime, function() self.timerAttack, self.canAttack = nil, true end)
			self:fire(entities)
		end
	end

	if map:collideHole(self.collideArea) then
		self:takeDmg(5)
	end
end

function FireSlime:fire(entities)
	for _,e in ipairs(entities) do
		if e.id ~= self.id and self.fireSegment:collide(e.collideArea) then
			e:takeDmg(self.dmg)
			local normal = self.vectorFire:normal()
			e.speed = e.speed + normal * ((math.random(0,1) -0.5) *2 * self.power) 
		end
	end
end

function FireSlime:onDeath()

end

function FireSlime:onCollide(entity)

end

function FireSlime:drawUI()
	local ratio = self.life/self.maxLife
	local r = self.collideArea.forms[1].r
	local lifeBox = EasyLD.box:new(self.pos.x - r, self.pos.y - 3*r/2, r * 2 * ratio , 2, EasyLD.color:new(255,0,0))
	lifeBox:draw()
end

function FireSlime:draw()
	if self.spriteAnimation ~= nil then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
	end

	if self.isPlayer then
		self.fireSegment:draw()
	end

	font:print(self.life .. "/"..self.maxLife, 16, EasyLD.box:new(self.pos.x, self.pos.y, 50, 20), nil, nil, EasyLD.color:new(0,0,255))
end

return FireSlime