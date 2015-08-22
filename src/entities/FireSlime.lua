local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local FireSlime = class('FireSlime', Entity)

function FireSlime:load()
	self.isPlayer = false
	self.power = 100
	self.dmg = 5
	self.life = 10
	self.maxLife = 10

	self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos:copy())
end

function FireSlime:update(dt, entities)
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

		local vectorFire = EasyLD.vector:of(self.pos, DM:getMousePos())
		vectorFire:normalize()
		self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos + (vectorFire * self.power), EasyLD.color:new(255,0,0))
		
		if EasyLD.mouse:isPressed("l") then
			self:fire(entities)
		end
	else

	end
end

function FireSlime:fire(entities)
	for _,e in ipairs(entities) do
		if e.id ~= self.id and self.fireSegment:collide(e.collideArea) then
			e:takeDmg(self.dmg)
		end
	end
end

function FireSlime:onDeath()

end

function FireSlime:onCollide(entity)

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