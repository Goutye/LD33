local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local GameScreen = class('GameScreen', IScreen)

local EndScreen = require 'screens.EndScreen'

local FireSlime = require 'entities.FireSlime'
local ExplodeSlime = require 'entities.ExplodeSlime'
local PushSlime = require 'entities.PushSlime'

local Treasure = require 'entities.Treasure'

local Hero = require 'entities.Hero'

function GameScreen:initialize(level, gamedata)
	self.newScreen = false
	self.tl = EasyLD.tileset:new("assets/tilesets/dungeon.png", 32)

	if gamedata == nil then
		self.floors = {1, 2}--, 3 ,4 ,5 ,6}
		self.money = 0
		self.heroesDefeated = {}
	else
		self.floors = gamedata.floors
		for i = 1, #self.floors do
			print("XX: "..self.floors[i])
		end
		self.money = gamedata.money
		self.heroesDefeated = gamedata.heroesDefeated
	end

	self.nbFloors = #self.floors

	self.maps = {}
	self.maps[1] = EasyLD.map:new("assets/maps/map1.map", self.tl)
	self.maps[2] = EasyLD.map:new("assets/maps/map2.map", self.tl)
	self.maps[3] = EasyLD.map:new("assets/maps/map3.map", self.tl)
	self.maps[4] = EasyLD.map:new("assets/maps/map4.map", self.tl)
	self.maps[5] = EasyLD.map:new("assets/maps/ludum.map", self.tl)
	self.maps[6] = EasyLD.map:new("assets/maps/treasure.map", self.tl)

	self.maps[1].name = "The entrance"
	self.maps[2].name = "The foundry"
	self.maps[3].name = "Pillars of Arraks"
	self.maps[4].name = "The secret corridor"
	self.maps[5].name = "The Ratking's\n laboratory"
	self.maps[6].name = "Treasure Halls"

	self.centerOn = {}
	self.centerOn[1] = {200, 900, true}
	self.centerOn[2] = {300, 700, true}
	self.centerOn[3] = {400, 500, true}
	self.centerOn[4] = {200, 300, true}
	self.centerOn[5] = {200, 300, true}
	self.centerOn[6] = {200, 300, true}

	self.moneyRequired = {50, 100, 200, 500, 1000}

	self.randomStrings = {}
	self.randomStrings[1] = {"Here is Paladin Fordring! Put your faith in the light!",
							"Lord Snow, here I am and here I stay! Winter is coming!"}
	self.randomStrings[2] = {self.maps[2].name .. "... As if this can stop me!",
							"By the light! ".. self.maps[2].name .." will be purified!"}
	self.randomStrings[3] = {"Pillars... What if I destroyed some of them?",
							"The light is rising! For the argent crusade!"}
	self.randomStrings[4] = {"The nest of your Arakkoa? Time to shine!",
							"So it is true. One more reason to put them down!"}
	self.randomStrings[5] = {"And here we are, your famous heart of darkness\nRatking's laboratory.",
							"The Ludum Da Ray legion is arriving. Shine, Crusaders!"}
	self.randomStrings[6] = {"Look at me, Mike Kasprzak! I did a total clean up in these dungeon,\n I will do the same in your LD castle! Prepare yourself!",
							"And this is the end for your demons, Jaraxxus. Bow down to the light!",
							"Olley..."}

	self.maps[1].pointOfInterest = EasyLD.point:new(620,370)
	self.maps[2].pointOfInterest = EasyLD.point:new(745,505)
	self.maps[3].pointOfInterest = EasyLD.point:new(580, 312)
	self.maps[4].pointOfInterest = EasyLD.point:new(618, 240)
	self.maps[5].pointOfInterest = EasyLD.point:new(518,680)

	self.player = FireSlime:new(568, 615, EasyLD.area:new(EasyLD.circle:new(568, 615, 16, EasyLD.color:new(0,0,0,0))))
	self.player.depth = 0
	self.player.isPlayer = true

	self.slices = {}
	self.slices[1] = EasyLD.worldSlice:new(self.maps[1], EasyLD.point:new(0,100))
	self.slices[2] = EasyLD.worldSlice:new(self.maps[2], EasyLD.point:new(0,0))
	self.slices[3] = EasyLD.worldSlice:new(self.maps[3], EasyLD.point:new(80,100)) 
	self.slices[4] = EasyLD.worldSlice:new(self.maps[4], EasyLD.point:new(0,100)) 
	self.slices[5] = EasyLD.worldSlice:new(self.maps[5], EasyLD.point:new(150,96)) 

	self.slices[1]:addEntity(self.player)
	self.slices[1]:addEntity(ExplodeSlime:new(220, 230, EasyLD.area:new(EasyLD.circle:new(220, 230, 12, EasyLD.color:new(0,0,0,0)))))
	self.slices[1]:addEntity(FireSlime:new(276, 376, EasyLD.area:new(EasyLD.circle:new(276, 376, 12, EasyLD.color:new(0,0,0,0)))))
	self.slices[1]:addEntity(FireSlime:new(186, 376, EasyLD.area:new(EasyLD.circle:new(186, 376, 12, EasyLD.color:new(0,0,0,0)))))

	--self.slices[2]:addEntity(PushSlime:new(128, 308, EasyLD.area:new(EasyLD.circle:new(128, 308, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[2]:addEntity(PushSlime:new(228, 168, EasyLD.area:new(EasyLD.circle:new(228, 168, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[2]:addEntity(PushSlime:new(228, 472, EasyLD.area:new(EasyLD.circle:new(228, 472, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[2]:addEntity(ExplodeSlime:new(228, 308, EasyLD.area:new(EasyLD.circle:new(228, 308, 12, EasyLD.color:new(0,0,0,0)))))
	

	--self.slices[3]:addEntity(PushSlime:new(550, 370, EasyLD.area:new(EasyLD.circle:new(550, 370, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[3]:addEntity(FireSlime:new(662, 260, EasyLD.area:new(EasyLD.circle:new(662, 260, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[3]:addEntity(FireSlime:new(188, 250, EasyLD.area:new(EasyLD.circle:new(188, 250, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[3]:addEntity(FireSlime:new(188, 440, EasyLD.area:new(EasyLD.circle:new(188, 440, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[3]:addEntity(ExplodeSlime:new(370, 370, EasyLD.area:new(EasyLD.circle:new(370, 370, 12, EasyLD.color:new(0,0,0,0)))))

	--self.slices[4]:addEntity(FireSlime:new(300, 228, EasyLD.area:new(EasyLD.circle:new(300, 228, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[4]:addEntity(PushSlime:new(750, 228, EasyLD.area:new(EasyLD.circle:new(750, 228, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[4]:addEntity(PushSlime:new(718, 240, EasyLD.area:new(EasyLD.circle:new(718, 240, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[4]:addEntity(PushSlime:new(788, 260, EasyLD.area:new(EasyLD.circle:new(788, 260, 12, EasyLD.color:new(0,0,0,0)))))

	--self.slices[5]:addEntity(ExplodeSlime:new(482, 400, EasyLD.area:new(EasyLD.circle:new(482, 400, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[5]:addEntity(PushSlime:new(206, 246, EasyLD.area:new(EasyLD.circle:new(206, 246, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[5]:addEntity(PushSlime:new(786, 246, EasyLD.area:new(EasyLD.circle:new(786, 246, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[5]:addEntity(PushSlime:new(300, 660, EasyLD.area:new(EasyLD.circle:new(300, 660, 12, EasyLD.color:new(0,0,0,0)))))
	--self.slices[5]:addEntity(PushSlime:new(706, 660, EasyLD.area:new(EasyLD.circle:new(706, 660, 12, EasyLD.color:new(0,0,0,0)))))

	self.hero = Hero:new(220, 550, EasyLD.area:new(EasyLD.circle:new(220, 550, 12, EasyLD.color:new(0, 255, 0))))
	self.hero:load(level or 0)
	self.hero:addPointOfInterest(self.maps[1].pointOfInterest)
	self.hero:speak(self.randomStrings[self.player.depth + 1][math.random(1, 2)], 3)
	self.slices[1]:addEntity(self.hero)

	self.isNewFloor = true
	self.timeEntrance = 4
	self.idCurrent = 1

	self:prepareTreasure()

	DM = EasyLD.depthManager:new(self.player, self.slices[1], 1, 0, math.min(self.nbFloors - 1, 2), 250)

	DM:addDepth(1, 0.8, self.slices[2], 250)
	if self.nbFloors > 2 then
		DM:addDepth(2, 0.66, self.slices[3], 250)
	end
	DM:centerOn(self.centerOn[1][1], self.centerOn[1][2])
	DM:follow(self.player, 0.5)
	self.DM = DM
end

function GameScreen:preCalcul(dt)
	return dt
end

function GameScreen:prepareTreasure()
	local pos = self.maps[self.nbFloors - 1].pointOfInterest:copy()
	local id = self.nbFloors
	self.maps[#self.maps].pointOfInterest = EasyLD.point:new(pos.x +  96 + 40, pos.y -8)
	self.maps[self.nbFloors].name = self.maps[#self.maps].name
	self.randomStrings[self.nbFloors] = self.randomStrings[#self.maps]
	self.slices[self.nbFloors] = EasyLD.worldSlice:new(self.maps[#self.maps], EasyLD.point:new(pos.x - 172, pos.y - 312))
	self.slices[self.nbFloors]:addEntity(Treasure:new(pos.x + 96, pos.y - 8, EasyLD.area:new(EasyLD.box:new(pos.x + 96, pos.y - 8, 16, 16, EasyLD.color:new(0,255,0)))))
end

function GameScreen:update(dt)
	if EasyLD.mouse:isPressed("r") then
		self.hero.life = 0
	end
	self.DM:update(dt)

	if self.idCurrent == #self.floors then
		if self.hero:hasGotTreasure() then
			self.timerEnd = EasyLD.timer.after(2, function()
					EasyLD:nextScreen(EndScreen:new({floors = self.floors, money = self.money, heroesDefeated = self.heroesDefeated, lastHero = self.hero}), "cover", {0,1}, 3, true, "bounceout")
				end)
		end
	elseif self.hero.isDead and not self.newScreen and not self.timerNewScreen then
		self.timerNewScreen = EasyLD.timer.after(0.5, function()
			self.newScreen = true
			self.timerNewScreen = nil

			local baseMoney = 50
			self.hero.money = math.floor((self.hero.level+1) * baseMoney + (math.random() * (self.hero.level + 1)) * baseMoney)
			self.money = self.money + self.hero.money
			local reduceMoney = 0
			if self.money >= baseMoney * (self.hero.level + 1) and #self.maps > #self.floors then
				table.insert(self.floors, #self.floors + 1)
				reduceMoney = baseMoney * (self.hero.level + 1) 
			end
			table.insert(self.heroesDefeated, self.hero)
			EasyLD:nextScreen(GameScreen:new(self.hero.level + 1, {floors = self.floors, money = self.money - reduceMoney, heroesDefeated = self.heroesDefeated}), "fade", nil, 5, true, "quad")
		end	)
	elseif self.hero:isPointOfInterestReached(self.maps[self.player.depth + 1]) then
		self.slices[self.idCurrent]:removeEntity(self.hero)
		self.slices[self.idCurrent + 1]:addEntity(self.hero)
		
		self.hero:addPointOfInterest(self.maps[self.idCurrent + 1].pointOfInterest)
		self.hero.canAttack = true
		self.hero.choice = nil
		self.hero.timeBeforeRunning = 2
		self.hero:isLanding()

		self.timer = EasyLD.flux.to(self.DM.depth[self.player.depth + 1], 2, {ratio = 1}):ease("backinout")
		if self.idCurrent < #self.floors - 1 then
			self.timer3 = EasyLD.flux.to(self.DM.depth[self.player.depth + 2], 2, {ratio = 0.8}):ease("backinout")
		end
		self.timer2 = EasyLD.flux.to(self.DM.depth[self.player.depth], 2, {alpha = 0}):oncomplete(
			function()
				if #self.floors > self.idCurrent + 1 then
					self.DM:moveUp()
					self.player.depth = self.player.depth - 1
					self.DM:addDepth(2, 0.66, self.slices[self.idCurrent + 2], 250)
					--self.timer2 = EasyLD.flux.to(self.DM.depth[1], 1, {ratio = 0.66}):onupdate(function() self.DM.depth[1].alpha = 250 end)
				end
			end)

		local oldDepth = self.player.depth
		self.player = self.slices[self.idCurrent + 1].entities[1]
		self.player.isPlayer = true
		self.player.depth = oldDepth + 1
		self.idCurrent = self.idCurrent +1
		self.DM:follow(self.player, 0.5)
		if self.idCurrent <= #self.centerOn then
			self.DM:centerOn(unpack(self.centerOn[self.idCurrent]))
		end

		self.hero:speak(self.randomStrings[self.idCurrent][math.random(1, 2)], 5)
		self.isNewFloor = true
		self.timeEntrance = 5
	end

	if EasyLD.keyboard:isPressed(" ") or (self.player.isDead and #self.slices[self.player.depth + 1].entities > 1) then
		local oldId = self.player.id
		local oldDepth = self.player.depth
		
		local newId = (oldId % #self.slices[self.idCurrent].entities) + 1
		if newId == self.hero.id then newId = (newId % #self.slices[self.idCurrent].entities) + 1 end

		if newId ~= oldId then
			self.player.isPlayer = false
			self.player = self.slices[self.idCurrent].entities[newId]
			self.player.isPlayer = true
			self.player.depth = oldDepth
			self.DM:follow(self.player, 0.5)
		end
	end
end

function GameScreen:draw()
	self.DM:draw()
	--EasyLD.postfx:use("vignette", 0.6, 0.1, 0.1)
	font:print("Floors: " .. self.nbFloors, 40, EasyLD.box:new(0,0,EasyLD.window.w, 50), nil, nil, EasyLD.color:new(255,255,255))
	if self.nbFloors < #self.maps then
		moneyText ="Money: " .. self.money .. "/" .. self.moneyRequired[self.nbFloors - 1]
	else
		moneyText ="Money: " .. self.money
	end
	font:print(moneyText, 40, EasyLD.box:new(0,40,EasyLD.window.w, 50), nil, nil, EasyLD.color:new(255,255,255))
	font:print(self.maps[self.idCurrent].name, 60, EasyLD.box:new(0,0,EasyLD.window.w, 50), "center", nil, EasyLD.color:new(255,255,255))
	font:print("Heros ",40, EasyLD.box:new(0,0,EasyLD.window.w, 50), "right", nil, EasyLD.color:new(255,255,255))
	font:print("crushed",40, EasyLD.box:new(0,40,EasyLD.window.w, 50), "right", nil, EasyLD.color:new(255,255,255))

	font:print(self.hero.level.." :       ",40, EasyLD.box:new(0,16,EasyLD.window.w, 50), "right", nil, EasyLD.color:new(255,255,255))
end

function GameScreen:onEnd()

end

return GameScreen