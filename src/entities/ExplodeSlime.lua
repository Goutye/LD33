local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local ExplodeSlime = class('ExplodeSlime', Entity)

function ExplodeSlime:load()
	self.isPlayer = false
	self.power = 150
	self.dmg = 0
	self.life = 10
	self.maxLife = 10

	self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos:copy())
end

function ExplodeSlime:update(dt, entities)
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

		self.explodeCircle = EasyLD.circle:new(self.pos.x, self.pos.y, self.power, EasyLD.color:new(255, 0, 0, 200))
		
		if EasyLD.mouse:isPressed("l") then
			self:explode(entities)
		end
	else

	end
end

function ExplodeSlime:explode(entities)
	for _,e in ipairs(entities) do
		if e.id ~= self.id and self.explodeCircle:collide(e.collideArea) then
			local dir = EasyLD.vector:of(self.pos, e.pos)
			local distance = dir:length()
			dir:normalize() 
			local ratio = 1 - distance / self.power
			e:takeDmg(ratio * self.dmg)
			e.speed = e.speed + (dir * ratio * self.power * 6)
		end
	end
end

function ExplodeSlime:onDeath()

end

function ExplodeSlime:onCollide(entity)

end

function ExplodeSlime:draw()
	if self.spriteAnimation ~= nil then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
	end

	if self.isPlayer then
		self.explodeCircle:draw()
	end

	font:print(self.life .. "/"..self.maxLife, 16, EasyLD.box:new(self.pos.x, self.pos.y, 50, 20), nil, nil, EasyLD.color:new(0,0,255))
end

return ExplodeSlime