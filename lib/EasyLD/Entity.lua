local class = require 'EasyLD.lib.middleclass'

local Entity = class('Entity')

local MAX_SPEED = 500
local SQUARED_MAX_SPEED = MAX_SPEED * MAX_SPEED
local FRICTION = 0.95

function Entity:initialize(x, y, collideArea, spriteAnimation)
	self.pos = EasyLD.point:new(x, y)
	self.speed = EasyLD.vector:new(0, 0)
	self.acceleration = EasyLD.vector:new(0, 0)

	self.collideArea = collideArea
	self.spriteAnimation = spriteAnimation
	
	self.isDead = false
	self.life = 0
	self.maxLife = 0

	self:load()
end

function Entity:load()

end

function Entity:copy()
	local e = Entity:new(self.pos.x, self.pos.y, self.collideArea:copy(), self.spriteAnimation)
	e.update = self.update
	e.onDeath = self.onDeath
	e.onCollide = self.onCollide
	e.draw = self.draw
	e.load = self.load
	e:load()

	return e
end

function Entity:update(dt)
	--Here update speed or acceleration
end

function Entity:collide(otherEntity)
	return self.collideArea and otherEntity.collideArea and self.collideArea:collide(otherEntity.collideArea)
end

function Entity:moveTo(x, y)
	self.pos.x = x
	self.pos.y = y
	self.collideArea:moveTo(x,y)
end

function Entity:tryMove(dt, map, entities)
	if self.acceleration.x ~= 0 or self.acceleration.y ~= 0 then
		self.speed = self.speed + (self.acceleration * dt)
	end
	if self.speed.x ~= 0 or self.speed.y ~= 0 then
		local squaredSpeed = self.speed:squaredLength()
		
		if squaredSpeed > SQUARED_MAX_SPEED then
			self.speed = self.speed - (self.acceleration * dt)
		end
	else
		return
	end

	local nextPos = self.pos:copy()

	if self.collideArea then --If it is not a passive entity
		nextPos = self.pos + self.speed * dt
		self.collideArea:moveTo(nextPos.x, self.pos.y)

		local collide = false

		if map:collide(self.collideArea) then
			self.speed.x = 0
		end

		self.collideArea:moveTo(self.pos.x, nextPos.y)

		if map:collide(self.collideArea) then
			self.speed.y = 0
		end

		nextPos = self.pos + self.speed * dt
		self.collideArea:moveTo(nextPos.x, nextPos.y)
		if map:collide(self.collideArea) then
			collide = true
			self.speed.x = 0
			self.speed.y = 0
		end


		for id, entity in ipairs(entities) do
			if id ~= self.id and self:collide(entity) then
				entity:onCollide(self)
				self:onCollide(entity)
				collide = true
			end
		end

		if collide then
			self.collideArea:moveTo(self.pos.x, self.pos.y)
		else
			self.pos = self.pos + self.speed * dt
		end
	else
		self.pos = self.pos + self.speed * dt
	end

	self.speed = self.speed * FRICTION
end

function Entity:draw()
	if self.spriteAnimation ~= nil then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
	end
end

function Entity:takeDmg(dmg)
	self.life = self.life - dmg
	if self.life <= 0 then
		self.isDead = true
		self.life = 0
	end
end

function Entity:onDeath()

end

function Entity:onCollide(entity)

end

return Entity