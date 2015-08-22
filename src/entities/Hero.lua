local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local Hero = class('Hero', Entity)

function Hero:load(level)
	if level == nil then level = 0 end
	self.isHero = true
	self.level = level
	self.distance = 50
	self.dmg = 10 + level * 2
	self.life = 100 + level * 10
	self.maxLife = 100 + level * 10
	self.choice = nil
	self.canAttack = true
	self.reloadTime = 0.5 - level *0.01
	if self.reloadTime < 0.25 then self.reloadTime = 0.25 end 
	self.gotTresure = false

	self.swordSegment = EasyLD.segment:new(self.pos:copy(), self.pos:copy())

	self.PS = EasyLD.particles:new(self.pos, "assets/smoke.png")
	self.PS:setEmissionRate({[0] = 20, [1] = 1}, {"quadout"})
	self.PS:setLifeTime(1)
	self.PS:setInitialVelocity(50)
	self.PS:setInitialAcceleration(-50)
	self.PS:setDirection(0, math.pi * 2)
	self.PS:setColors({[0] = EasyLD.color:new(255,255,255,200),
						[1] = EasyLD.color:new(255,255,255,0)})
	self.PS:setSizes({[0] = 64,
						[1] = 16})
	self.PS:start()
end

function Hero:update(dt, entities, map)
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

	local direction = self:findPath(map, self.choice.pos)
	self.acceleration = direction * ACCELERATION

	local vectorSword = EasyLD.vector:of(self.pos, self.choice.pos)
	vectorSword:normalize()

	if self.acceleration:squaredLength() == 0 then
		self.acceleration = vectorSword * ACCELERATION
	end

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

	if map:collideHole(self.collideArea) then
		self:takeDmg(5)
	end

	self.PS.follower:moveTo(self.pos.x, self.pos.y)
	self.PS:update(dt)
end

function Hero:findPath(map, goal)
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

		if pos.x > 0 and pos.x < map.w and pos.y > 0 and pos.y < map.h and map:getInfos(pos.x, pos.y) == 0 and pos.w < mapWeight[pos.x][pos.y] then
			mapWeight[pos.x][pos.y] = pos.w
			table.insert(nextPos, {x = pos.x + 1, y = pos.y, w = pos.w + 1})
			table.insert(nextPos, {x = pos.x - 1, y = pos.y, w = pos.w + 1})
			table.insert(nextPos, {x = pos.x, y = pos.y + 1, w = pos.w + 1})
			table.insert(nextPos, {x = pos.x, y = pos.y - 1, w = pos.w + 1})
		end
	end

	-- for j = 0, #mapWeight[0] - 1 do
	-- 	local str = ""
	-- 	for i = 0, #mapWeight - 1 do
	-- 		str = str .. mapWeight[i][j] .. ", "
	-- 	end
	-- 	print (str)
	-- end

	local _,x,y = map:getTilePixel(self.pos.x, self.pos.y)
	local bestx, besty = 0, 0
	local best = 9999
	for i = x - 2, x + 2 do
		if i >= 0 and i < map.w then
			for j = y - 2, y + 2 do
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

	local dir = EasyLD.vector:of(EasyLD.point:new(x, y), EasyLD.point:new(bestx, besty))
	if dir:squaredLength() ~= 0 then
		dir:normalize()
	end
	--print(dir.x, dir.y)
	return dir
end

function Hero:attack(entities)
	for _,e in ipairs(entities) do
		if e.id ~= self.id and self.swordSegment:collide(e.collideArea) then
			if e:takeDmg(self.dmg) then
				self:speak("One more!", 1)
			end
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

function Hero:isPointOfInterestReached(map)
	if self.choice.pos == self.pointOfInterest then
		if not DM.follower.isHero then
			self.depth = DM.follower.depth
			DM:follow(self, 0.5)
			local _,x,y = map:getTilePixel(self.pointOfInterest.x, self.pointOfInterest.y)
			map:putTile(10, x, y)
		end
		local dist = EasyLD.vector:of(self.pointOfInterest, self.pos)
		return dist:squaredLength() < 25
	end
end

function Hero:hasGotTreasure()
	return self.gotTresure
end

function Hero:drawUI()
	local ratio = self.life/self.maxLife
	local r = self.collideArea.forms[1].r
	local lifeBox = EasyLD.box:new(self.pos.x - r * 2, self.pos.y - 3*r/2, r * 4 * ratio , 4, EasyLD.color:new(255,0,0))
	lifeBox:draw()
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
		table.insert(list, EasyLD.point:new(x, y - 16))
		table.insert(list, EasyLD.point:new(x, y - 36))
		table.insert(list, EasyLD.point:new(x + 0.4 * size, y - 36))
		table.insert(list, EasyLD.point:new(x + 0.4 * size, y - 76))
		table.insert(list, EasyLD.point:new(x - 0.72 * size, y - 76))
		table.insert(list, EasyLD.point:new(x - 0.72 * size, y - 36))
		table.insert(list, EasyLD.point:new(x - 0.05 * size, y - 36))
		local polygon = EasyLD.polygon:new("fill", EasyLD.color:new(20, 20, 20, 240), unpack(list))
		polygon:draw()
		font:print(text, 20, EasyLD.box:new(x - 0.72 * size, y - 71, 1.12 * size, 20), "center", nil, EasyLD.color:new(255,255,255))
		end
	self.timerPopup = EasyLD.timer.after(time or 3, function() self.timerPopup, self.popup = nil, nil end)
end

function Hero:isLanding()
	self.PS:emit(70)
end

function Hero:draw()
	self.PS:draw()

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