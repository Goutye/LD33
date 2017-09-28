local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local ExplodeSlime = class('ExplodeSlime', Entity)

function ExplodeSlime:load()
	self.isPlayer = false
	self.power = 150
	self.dmg = 20
	self.life = 1000
	self.maxLife = 1000

	self.randomRatio = 0
	self.timeNextRandom = 0.2

	self.PS = EasyLD.particles:new(self.pos, "assets/smoke.png")
	self.PS:setEmissionRate(200)
	self.PS:setLifeTime(0.5)
	self.PS:setInitialVelocity(200)
	self.PS:setInitialAcceleration(0)
	self.PS:setDuration(0.5)
	self.PS:setDirection(0, math.pi*2)
	self.PS:setColors({[0] = EasyLD.color:new(255,255,255,200),
						[1] = EasyLD.color:new(255,255,255,0)})
	self.PS:setSizes({[0] = 32,
						[1] = 48})

	self.explodeCircle = EasyLD.circle:new(self.pos.x, self.pos.y, self.power, EasyLD.color:new(255, 0, 0, 200))
	self.spriteAnimation = EasyLD.spriteAnimation(self, "assets/sprites/ExplodeSlime.png", 4, 0.05, 32, 32, 0, -1, "center")
	self.spriteAnimation:play()
	self.pAnim = EasyLD.point:new(self.pos.x, self.pos.y, true)
	self.img = EasyLD.image:new("assets/sprites/shadow.png")
	self.pAnim2 = EasyLD.point:new(self.pos.x, self.pos.y, true)
	self.pAnim2:attachImg(self.img, "center")
	self.collideArea:attach(self.pAnim2)
	self.collideArea:attach(self.pAnim)
	self.pAnim:attachImg(self.spriteAnimation, "center")


	self.sfx = {}
	self.sfx.explode = EasyLD.sfx:new("assets/sfx/boom.wav", 0.4)
end

function ExplodeSlime:update(dt, entities, map)
	local ACCELERATION = 600

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
		
		if EasyLD.mouse:isPressed(1) or self.toExplode then
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

	self.PS.follower:moveTo(self.pos.x, self.pos.y)
	self.PS:update(dt)
end

function ExplodeSlime:explode(entities)
	if not self.isExploded then
		self.isExploded = true
		self.PS:start()
		self.sfx.explode:play()
		EasyLD.camera:shake({x = 25, y = 25}, 1, "sineout")
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
		self.timerDeath = EasyLD.timer.after(1, function() self.isDead = true end)
	end
end

function ExplodeSlime:onDeath()

end

function ExplodeSlime:onCollide(entity)

end

function ExplodeSlime:onDmg()
	if self.isPlayer then
		EasyLD.camera:tilt(EasyLD.vector:new(math.random()-0.5,math.random()-0.5), 10, 0.5)
	end


end

function ExplodeSlime:takeDmg(dmg)
	self.toExplode = true
	if not self.invincible then
		self.invincible = true
		self.timerInvincible = EasyLD.timer.after(self.timeBeforeNextDmg, function() self.timerInvincible, self.invincible = nil, false end)
		self.life = self.life - dmg
		if self.life <= 0 then
			self.isDead = true
			self.life = 0
			return true
		end
	end
end

function ExplodeSlime:drawUI()
	local ratio = self.life/self.maxLife
	local r = self.collideArea.forms[1].r
	local lifeBox = EasyLD.box:new(self.pos.x - r, self.pos.y - 3*r/2, r * 2 * ratio , 2, EasyLD.color:new(255,0,0))
	--lifeBox:draw()
end

function ExplodeSlime:draw()
	if self.spriteAnimation ~= nil and false then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
	end
	self.PS:draw()

	--font:print(self.life .. "/"..self.maxLife, 16, EasyLD.box:new(self.pos.x, self.pos.y, 50, 20), nil, nil, EasyLD.color:new(0,0,255))
end

return ExplodeSlime