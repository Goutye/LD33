local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local Hero = class('Hero', Entity)

function Hero:load()
	self.distance = 50
	self.dmg = 10
	self.life = 100
	self.maxLife = 100
	self.choice = nil
	self.canAttack = true
	self.reloadTime = 0.5
	self.gotTresure = false

	self.swordSegment = EasyLD.segment:new(self.pos:copy(), self.pos:copy())
end

function Hero:update(dt, entities)
	local ACCELERATION = 500

	self.acceleration = EasyLD.point:new(0, 0)

	if self.choice == nil or self.choice.isDead then
		self.choice = nil

		for _,e in ipairs(entities) do
			if e.id ~= self.id and not e.isDead then
				self.choice = e
			end
		end

		if self.choice == nil then
			self.choice = {pos = self.pointOfInterest}
			self.canAttack = false
			EasyLD.timer.cancel(self.timer)
			self.timer = nil
		end
	end

	local vectorSword = EasyLD.vector:of(self.pos, self.choice.pos)
	vectorSword:normalize()

	self.acceleration = vectorSword * ACCELERATION

	self.swordSegment = EasyLD.segment:new(self.pos:copy(), self.pos + (vectorSword * self.distance), EasyLD.color:new(0,100,255))

	if self.canAttack then
		if self.swordSegment:collide(self.choice.collideArea) then
			self:attack(entities)
			self.canAttack = false
			self.timer = EasyLD.timer.after(self.reloadTime, function() self.timer, self.canAttack, self.swordSegment.c = nil, true, EasyLD.color:new(0,100,255) end)
			self.swordSegment.c = EasyLD.color:new(0,255,100)
		end
	else
		self.swordSegment.c = EasyLD.color:new(0,255,100)
	end
end

function Hero:attack(entities)
	for _,e in ipairs(entities) do
		if e.id ~= self.id and self.swordSegment:collide(e.collideArea) then
			e:takeDmg(self.dmg)
		end
	end
end

function Hero:onDeath()

end

function Hero:onCollide(entity)

end

function Hero:addPointOfInterest(pointOfInterest)
	self.pointOfInterest = pointOfInterest
end

function Hero:isPointOfInterestReached()
	if self.choice.pos == self.pointOfInterest then
		local dist = EasyLD.vector:of(self.pointOfInterest, self.pos)
		return dist:squaredLength() < 1
	end
end

function Hero:hasGotTreasure()
	return self.gotTresure
end

function Hero:draw()
	if self.spriteAnimation ~= nil then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
	end

	if self.choice ~= nil then
		self.swordSegment:draw()
	end

	font:print(self.life .. "/"..self.maxLife, 16, EasyLD.box:new(self.pos.x, self.pos.y, 50, 20), nil, nil, EasyLD.color:new(0,0,255))
end

return Hero