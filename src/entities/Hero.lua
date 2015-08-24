local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local Hero = class('Hero', Entity)

Hero.firstname = {"Tirion", "John", "Sirius", "Sylvanas", "Jaime", "Mike", "Umaru", "Harry", "Hermione", "Ginny", "Haruihi", "Lelouch", "Moon", ""}
Hero.lastname = {"Fordring", "Snow", "Black", "Windrunner", "Lannister", "Kazprzak", "chan", "Potter", "Granger", "Weasley", "Suzumiya", "Lamperouge", "Moon"}

function Hero:load(level)
	if level == nil then return end
	math.randomseed( os.time() )
	self.firstname = Hero.firstname[math.random(1, #Hero.firstname)]
	self.lastname = Hero.lastname[math.random(1, #Hero.lastname)]
	print(self.firstname)
	self.name = self.firstname .. " " .. self.lastname
	self.isHero = true
	self.level = level
	self.distance = 50
	self.dmg = 5 + level * 2
	self.life = 40 + level * 10
	self.maxLife = 20 + level * 10
	self.choice = nil
	self.canAttack = true
	self.reloadTime = 0.5 - level *0.01
	if self.reloadTime < 0.25 then self.reloadTime = 0.25 end 
	self.gotTresure = false

	self.swordSegment = EasyLD.segment:new(self.pos:copy(), self.pos:copy())

	self.PS = EasyLD.particles:new(self.pos, "assets/smoke2.png")
	self.PS:setEmissionRate({[0] = 20, [1] = 1}, {"quadout"})
	self.PS:setLifeTime(1)
	self.PS:setInitialVelocity(30)
	self.PS:setInitialAcceleration(-50)
	self.PS:setDirection(0, math.pi * 2)
	self.PS:setColors({[0] = EasyLD.color:new(255,255,255,200),
						[1] = EasyLD.color:new(255,255,255,0)})
	self.PS:setSizes({[0] = 64,
						[1] = 16})
	self.PS:start()

	self.timeBeforeRunning = 1

	self.randomStringOnKill = {"One more for the light!",
								"Eats this, heinous monster!",
								"You will never be able to reign here!",
								"Is this all you got?",
								"Bless the sun!",
								"Umaru-chan, please notice me!",
								"By the divine hammer!",
								"Anduin will claim your soul!"}
	self.randomStringOnDeath = {"Arrrrrggggggggh. The light... The light should have come back...",
								".. I can only see black... darkness every...where..."}

	self.sfx = {}
	self.sfx.enter = EasyLD.sfx:new("assets/sfx/enter.wav", 0.7)
	self.sfx.isLanding = EasyLD.sfx:new("assets/sfx/isLanding.wav", 0.8)

	self.spriteAnimation = EasyLD.spriteAnimation(self, "assets/sprites/Hero.png", 4, 0.1, 32, 32, 0, -1, "center")
	self.spriteAnimation:play()
	self.pAnim = EasyLD.point:new(self.pos.x, self.pos.y, true)
	self.img = EasyLD.image:new("assets/sprites/shadow.png")
	self.pAnim2 = EasyLD.point:new(self.pos.x, self.pos.y, true)
	self.pAnim2:attachImg(self.img, "center")
	self.collideArea:attach(self.pAnim2)
	self.collideArea:attach(self.pAnim)
	self.pAnim:attachImg(self.spriteAnimation, "center")

	self.PS2 = EasyLD.particles:new(self.pos, "assets/smoke.png")
	self.PS2:setEmissionRate(200)
	self.PS2:setLifeTime(0.1)
	self.PS2:setInitialVelocity(600)
	self.PS2:setInitialAcceleration(0)
	self.PS2:setDirection(0, math.pi/36)
	self.PS2:setColors({[0] = EasyLD.color:new(255,255,255,150),
						[0.05] = EasyLD.color:new(255,187,1,150),
						[1] = EasyLD.color:new(255,187,0,0)})
	self.PS2:setSizes({[0] = 24,
						[0.3] = 23,
						[1] = 8})
	self.PS2:start()
end

function Hero:update(dt, entities, map)
	local ACCELERATION = 1000

	self.acceleration = EasyLD.point:new(0, 0)

	if self.choice == nil or self.choice.isDead then
		self.choice = nil

		bestChoice = nil
		bestDist = 999999999
		for _,e in ipairs(entities) do
			if e.id ~= self.id and not e.isDead then
				local v = EasyLD.vector:of(e.pos, self.pos)
				local d = v:squaredLength()
				if d < bestDist then
					bestDist = d
					bestChoice = e
				end
			end
		end

		self.choice = bestChoice

		if self.choice == nil then
			self.choice = {pos = self.pointOfInterest}
			self.canAttack = false
			EasyLD.timer.cancel(self.timer)
			self.timer = nil
		end
	end

	self.PS.follower:moveTo(self.pos.x, self.pos.y )--+ map.tileset.tileSizeY/2)
	self.PS:update(dt)

	if self.timeBeforeRunning > 0 then
		self.timeBeforeRunning = self.timeBeforeRunning - dt
		if self.timeBeforeRunning < 0 then
			self.sfx.enter:play()
		end
		return
	end

	if self.timerPathDir == nil then
		self.pathMap = self:findPath(map, self.choice.pos)
		self.timerPathDir = EasyLD.timer.after(0.5, function() self.timerPathDir = nil end)
	end
	local direction = self:findBestDir(map, self.pathMap)
	self.acceleration = direction * ACCELERATION

	local vectorSword = EasyLD.vector:of(self.pos, self.choice.pos)
	local dist = vectorSword:squaredLength()
	vectorSword:normalize()

	if self.acceleration:squaredLength() == 0 then
		self.acceleration = vectorSword * ACCELERATION
	end

	self.swordSegment = EasyLD.segment:new(self.pos:copy(), self.pos + (vectorSword * self.distance), EasyLD.color:new(150,150,0))

	if self.canAttack then
		if self.swordSegment:collide(self.choice.collideArea) then
			self:attack(entities, vectorSword)
			self.canAttack = false
			self.timer = EasyLD.timer.after(self.reloadTime, function() self.timer, self.canAttack, self.swordSegment.c = nil, true, EasyLD.color:new(0,100,255) end)
			self.swordSegment.c = EasyLD.color:new(0,255,100)
		end
	else
		self.swordSegment.c = EasyLD.color:new(0,255,100)
	end

	if map:collideHole(self.collideArea) then
		self:takeDmg(5)
	end

	self.pAnim.angle = vectorSword:getAngle() + math.pi/2
	self.PS2.follower:moveTo(self.pos.x + vectorSword.x * self.distance/4, self.pos.y + vectorSword.y * self.distance/4)
	self.PS2:setDirection(math.pi * 2 - vectorSword:getAngle(), math.pi/36)
	self.PS2:update(dt)
end

function Hero:findPath(map, goal)
	local tl, tlY = map.tileset.tileSize, map.tileset.tileSizeY
	local mapWeight = {}
	for i = 0, map.w - 1 do
		mapWeight[i] = {}
		for j = 0, map.h - 1 do
			mapWeight[i][j] = 9999
		end
	end

	local _,x,y = map:getTilePixel(goal.x, goal.y)
	local goalx, goaly = x, y
	mapWeight[x][y] = 0
	local nextPos = {{x = x + 1, y = y, w = 1}, {x = x - 1, y = y, w = 1}, {x = x, y = y + 1, w = 1}, {x = x, y = y - 1, w = 1}}

	while #nextPos ~= 0 do
		local pos = nextPos[1]
		table.remove(nextPos, 1)

		if pos.x > 0 and pos.x < map.w and pos.y > 0 and pos.y < map.h and pos.w < mapWeight[pos.x][pos.y] and map:getInfos(pos.x, pos.y) ~= 1 then
			local w = pos.w
			if map:getInfos(pos.x, pos.y) == 0 then
				w = w + 1
			elseif map:getInfos(pos.x, pos.y) == 2 then
				w = w + 5
			end

			mapWeight[pos.x][pos.y] = pos.w
			table.insert(nextPos, {x = pos.x + 1, y = pos.y, w = w})
			table.insert(nextPos, {x = pos.x - 1, y = pos.y, w = w})
			table.insert(nextPos, {x = pos.x, y = pos.y + 1, w = w})
			table.insert(nextPos, {x = pos.x, y = pos.y - 1, w = w})
		end
	end

	-- for j = 0, #mapWeight[0] - 1 do
	-- 	local str = ""
	-- 	for i = 0, #mapWeight - 1 do
	-- 		str = str .. mapWeight[i][j] .. ", "
	-- 	end
	-- 	print (str)
	-- end


	--print(dir.x, dir.y)
	return mapWeight
end

function Hero:findBestDir(map, mapWeight)
	local tl, tlY = map.tileset.tileSize, map.tileset.tileSizeY
	local _,x,y = map:getTilePixel(self.pos.x, self.pos.y)
	local bestx, besty = 0, 0
	local best = 9999
	for i = x - 1, x + 1 do
		if i >= 0 and i < map.w then
			for j = y - 1, y + 1 do
				if j >= 0 and j < map.h then
					local w = mapWeight[i][j]
					if w ~= nil and w < best then
						best = w
						bestx = i
						besty = j 
					end
				end
			end
		end
	end


	--print(self.pos.x, self.pos.y, x, y, goalx, goaly, goal.x, goal.y)

	local dir = EasyLD.vector:of(EasyLD.point:new(self.pos.x, self.pos.y), EasyLD.point:new(bestx * map.tileset.tileSize + tl/2 + map.offset.x, besty * map.tileset.tileSizeY+ tlY/2 + map.offset.y))
	if dir:squaredLength() ~= 0 then
		dir:normalize()
	end

	return dir
end

function Hero:attack(entities, vectorSword)
	self.PS2:emit(550)
	for _,e in ipairs(entities) do
		if e.id ~= self.id and self.swordSegment:collide(e.collideArea) then
			if e.isPlayer then
				EasyLD.camera:tilt(vectorSword, 20, 0.5)
			end
			if e:takeDmg(self.dmg) then
				self:speak(self.randomStringOnKill[math.random(1,#self.randomStringOnKill)], 1.5)
			end
		end
	end
end

function Hero:onDeath()
	self:speak(self.randomStringOnDeath[math.random(1, #self.randomStringOnDeath)], 2.5)
end

function Hero:onDmg()
	DM[#DM].sfx.hit:play()
end

function Hero:onCollide(entity)
end

function Hero:addPointOfInterest(pointOfInterest)
	self.pointOfInterest = pointOfInterest
end

function Hero:isPointOfInterestReached(map)
	if self.choice ~= nil and self.choice.pos == self.pointOfInterest then
		if not DM[#DM].follower.isHero then
			self.depth = DM[#DM].follower.depth
			DM[#DM]:follow(self, 0.5)
			local _,x,y = map:getTilePixel(self.pointOfInterest.x, self.pointOfInterest.y)
			map:putTile(10, x, y)
		end
		local dist = EasyLD.vector:of(self.pointOfInterest, self.pos)
		return dist:squaredLength() < 172
	end
end

function Hero:hasGotTreasure()
	return self.gotTreasure
end

function Hero:drawUI()
	local ratio = self.life/self.maxLife
	local r = self.collideArea.forms[1].r
	local lifeBoxC = EasyLD.box:new(self.pos.x - r * 2-1, self.pos.y - 3*r/2-1, r * 4 * ratio+2 , 4+2, EasyLD.color:new(0,0,0))
	local lifeBox = EasyLD.box:new(self.pos.x - r * 2, self.pos.y - 3*r/2, r * 4 * ratio , 4, EasyLD.color:new(200,0,0))
	self.nameSize = font:sizeOf(self.name, 12)
	lifeBoxC:draw()
	lifeBox:draw()
	font:printOutLine(self.name, 12, EasyLD.box:new(self.pos.x - self.nameSize /2, self.pos.y - 5*r/2, self.nameSize , 12), "center", nil, EasyLD.color:new(255,255,255,240), EasyLD.color:new(0, 0, 0, 240), 1)
	if self.popup then
		self.popup()
	end
end

function Hero:speak(text, time)
	if self.timerPopup then
		EasyLD.timer.cancel(self.timerPopup)
	end
	self.popup = function()
		local x, y = self.pos.x, self.pos.y
		local size = font:sizeOf(text, 20)
		local list = {}
		table.insert(list, EasyLD.point:new(x - 0.05 * size, y - 36))
		table.insert(list, EasyLD.point:new(x - 0.72 * size, y - 36))
		table.insert(list, EasyLD.point:new(x - 0.72 * size, y - 76))
		table.insert(list, EasyLD.point:new(x + 0.4 * size, y - 76))
		table.insert(list, EasyLD.point:new(x + 0.4 * size, y - 36))
		table.insert(list, EasyLD.point:new(x, y - 36))
		table.insert(list, EasyLD.point:new(x, y - 16))


		
		local polygon = EasyLD.polygon:new("fill", EasyLD.color:new(20, 20, 20, 240), unpack(list))

		local list2 = {}
		table.insert(list2, EasyLD.point:new(x - 0.05 * size - 3, y - 36 + 3))
		table.insert(list2, EasyLD.point:new(x - 0.72 * size - 3, y - 36 + 3))
		table.insert(list2, EasyLD.point:new(x - 0.72 * size - 3, y - 76 - 3))
		table.insert(list2, EasyLD.point:new(x + 0.4 * size +3, y - 76 - 3))
		table.insert(list2, EasyLD.point:new(x + 0.4 * size +3, y - 36 + 3))
		table.insert(list2, EasyLD.point:new(x, y - 36+3))
		table.insert(list2, EasyLD.point:new(x, y - 16+3))

		local polygon2 = EasyLD.polygon:new("fill", EasyLD.color:new(10, 10, 10, 240), unpack(list2))
		polygon2:draw()
		polygon:draw()
		font:print(text, 20, EasyLD.box:new(x - 0.72 * size, y - 71, 1.12 * size, 20), "center", nil, EasyLD.color:new(255,255,255))
		end
	self.timerPopup = EasyLD.timer.after(time or 3, function() self.timerPopup, self.popup = nil, nil end)
end

function Hero:isLanding()
	self.PS:emit(20)
	self.sfx.isLanding:play()
end

function Hero:draw()
	self.PS:draw()

	if self.spriteAnimation ~= nil and false then
		--self.spriteAnimation:draw(self.pos.x, self.pos.y)
	else
		self.pAnim:draw() --Comment this line for real, if test, uncomment
	end

	if self.choice ~= nil then
		--self.swordSegment:draw()
		self.collideArea:draw()
	end

	--font:print(self.life .. "/"..self.maxLife, 16, EasyLD.box:new(self.pos.x, self.pos.y, 50, 20), nil, nil, EasyLD.color:new(0,0,255))
end

return Hero