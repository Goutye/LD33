local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local ExplodeSlime = class('ExplodeSlime', Entity)

function ExplodeSlime:load()
	self.isPlayer = false
	self.power = 150
	self.dmg = 20
	self.life = 10
	self.maxLife = 10

	self.randomRatio = 0
	self.timeNextRandom = 0.2

	self.explodeCircle = EasyLD.circle:new(self.pos.x, self.pos.y, self.power, EasyLD.color:new(255, 0, 0, 200))
end

function ExplodeSlime:update(dt, entities, map)
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
		self.explodeCircle = EasyLD.circle:new(self.pos.x, self.pos.y, self.power * self.randomRatio, EasyLD.color:new(255, 0, 0, 200))
		if self.hero == nil then
			for _,e in ipairs(entities) do
				if e.level ~= nil then
					self.hero = e
					break
				end
			end
		end

		if self.timerRandom == nil then
			self.timerRandom = EasyLD.timer.after(self.timeNextRandom, function() self.timerRandom, self.randomRatio = nil, math.random() * 0.8 + 0.1 end)
		end

		if self.hero ~= nil and self.hero.collideArea:collide(self.explodeCircle) then
			self:explode(entities)
		end
	end

	if map:collideHole(self.collideArea) then
		self:takeDmg(5)
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
	self:takeDmg(self.dmg)
end

function ExplodeSlime:onDeath()

end

function ExplodeSlime:onCollide(entity)

end

function ExplodeSlime:drawUI()
	local ratio = self.life/self.maxLife
	local r = self.collideArea.forms[1].r
	local lifeBox = EasyLD.box:new(self.pos.x - r, self.pos.y - 3*r/2, r * 2 * ratio , 2, EasyLD.color:new(255,0,0))
	lifeBox:draw()
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