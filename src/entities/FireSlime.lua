local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local FireSlime = class('FireSlime', Entity)

function FireSlime:load()
	self.isPlayer = false
	self.power = 160
	self.dmg = 5
	self.life = 10
	self.maxLife = 10
	self.canAttack = true
	self.reloadTime = 1
	self.vectorFire = EasyLD.vector:new(0,0)
	self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos:copy())

	self.PS = EasyLD.particles:new(self.pos, "assets/smoke.png")
	self.PS:setEmissionRate(200)
	self.PS:setLifeTime(0.1)
	self.PS:setInitialVelocity(900)
	self.PS:setInitialAcceleration(0)
	self.PS:setDuration(self.reloadTime)
	self.PS:setDirection(0, math.pi/36)
	self.PS:setColors({[0] = EasyLD.color:new(0,0,0,200),
						[0.2] = EasyLD.color:new(255,0,0,200),
						[1] = EasyLD.color:new(255,2,0,0)})
	self.PS:setSizes({[0] = 16,
						[0.2] = 18,
						[1] = 16})
	self.spriteAnimation = EasyLD.spriteAnimation(self, "assets/sprites/FireSlime.png", 3, 0.5, 32, 32, 0, -1, "center")
	self.spriteAnimation:play()
	self.pAnim = EasyLD.point:new(self.pos.x, self.pos.y, true)
	self.img = EasyLD.image:new("assets/sprites/shadow.png")
	self.pAnim2 = EasyLD.point:new(self.pos.x, self.pos.y, true)
	self.pAnim2:attachImg(self.img, "center")
	self.collideArea:attach(self.pAnim2)
	self.collideArea:attach(self.pAnim)
	self.pAnim:attachImg(self.spriteAnimation, "center")

	self.sfx = EasyLD.sfx:new("assets/sfx/fire.wav", 0.4)
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

		self.vectorFire = EasyLD.vector:of(self.pos, DM[#DM]:getMousePos())
		self.vectorFire:normalize()
		self.PS:setDirection(math.pi * 2 - self.vectorFire:getAngle(), math.pi/36)
		self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos + (self.vectorFire * self.power), EasyLD.color:new(255,0,0))
		
		if EasyLD.mouse:isPressed("l") and self.canAttack then
			self.canAttack = false
			self.timerAttack = EasyLD.timer.after(self.reloadTime, function() self.timerAttack, self.canAttack = nil, true end)
			self:fire(entities)
		end
	elseif self.canAttack then
		if self.hero == nil then
			for _,e in ipairs(entities) do
				if e.level ~= nil then
					self.hero = e
					break
				end
			end
		end

		if self.hero ~= nil then
			self.vectorFire = EasyLD.vector:of(self.pos, self.hero.pos)
			self.vectorFire:normalize()
			self.fireSegment = EasyLD.segment:new(self.pos:copy(), self.pos + (self.vectorFire * self.power), EasyLD.color:new(255,0,0))
			self.PS:setDirection(math.pi * 2 - self.vectorFire:getAngle(), math.pi/36)
		end

		if self.hero ~= nil and self.hero.collideArea:collide(self.fireSegment) then
			self.canAttack = false
			self.timerAttack = EasyLD.timer.after(self.reloadTime, function() self.timerAttack, self.canAttack = nil, true end)
			self:fire(entities)
		end
	else 
		self.vectorFire = EasyLD.vector:of(self.pos, self.hero.pos)
		self.vectorFire:normalize()
	end

	if map:collideHole(self.collideArea) then
		self:takeDmg(5)
	end

	self.pAnim.angle = self.vectorFire:getAngle() + math.pi/2
	self.PS.follower:moveTo(self.pos:get())
	self.PS:update(dt)
end

function FireSlime:fire(entities)
	self.PS:start()
	self.sfx:play()
	self.timerPS = EasyLD.timer.after(0.5, function() self.PS:stop() end)
	for _,e in ipairs(entities) do
		if e.id ~= self.id and self.fireSegment:collide(e.collideArea) then
			e:takeDmg(self.dmg)
			local normal = self.vectorFire:normal()
			e.speed = e.speed + normal * ((math.random(0,1) -0.5) *2 * self.power) 
		end
	end
end

function FireSlime:onDeath()
	DM[#DM].sfx.death:play()
end

function FireSlime:onDmg()
	DM[#DM].sfx.hit:play()
	if self.isPlayer then
		EasyLD.camera:tilt(EasyLD.vector:new(math.random()-0.5,math.random()-0.5), 10, 0.5)
	end
end

function FireSlime:onCollide(entity)
	local v = EasyLD.vector:of(entity.pos, self.pos)
	v:normalize()
	self.speed = self.speed + entity.speed:length() * v
end

function FireSlime:drawUI()
	local ratio = self.life/self.maxLife
	local r = self.collideArea.forms[1].r
	local lifeBoxC = EasyLD.box:new(self.pos.x - r -1, self.pos.y - 3*r/2 - 1, r * 2 * ratio + 2 , 2+2, EasyLD.color:new(0,0,0))
	local lifeBox = EasyLD.box:new(self.pos.x - r, self.pos.y - 3*r/2, r * 2 * ratio , 2, EasyLD.color:new(200,00,0))
	lifeBoxC:draw()
	lifeBox:draw()
end

function FireSlime:draw()
	self.PS:draw()
	if self.spriteAnimation ~= nil and false then
		self.spriteAnimation:draw(self.pos.x, self.pos.y, 0)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
	end

	if self.isPlayer then
		--self.fireSegment:draw()
	end

	--font:print(self.life .. "/"..self.maxLife, 16, EasyLD.box:new(self.pos.x, self.pos.y, 50, 20), nil, nil, EasyLD.color:new(0,0,255))
end

return FireSlime