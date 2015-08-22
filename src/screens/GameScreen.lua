local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local GameScreen = class('GameScreen', IScreen)

local FireSlime = require 'entities.FireSlime'
local ExplodeSlime = require 'entities.ExplodeSlime'
local PushSlime = require 'entities.PushSlime'

local Treasure = require 'entities.Treasure'

local Hero = require 'entities.Hero'

function GameScreen:initialize(level, gamedata)
	self.newScreen = false
	self.tl = EasyLD.tileset:new("assets/tilesets/dungeon.png", 32)

	self.maps = {}
	self.maps[1] = EasyLD.map:new("assets/maps/map1.map", self.tl)
	self.maps[2] = EasyLD.map:new("assets/maps/map2.map", self.tl)
	self.maps[3] = EasyLD.map:new("assets/maps/treasure.map", self.tl)

	self.maps[1].name = "The entrance"
	self.maps[2].name = "The foundry"
	self.maps[3].name = "Treasure Halls"

	self.randomStrings = {}
	self.randomStrings[1] = {"Here is Paladin Fordring! Put your faith in the light!",
							"Lord Snow, here I am and here I stay! Winter is coming!"}
	self.randomStrings[2] = {self.maps[2].name .. "... As if this can stop me!",
							"By the light! ".. self.maps[2].name .." will be purified!"}
	self.randomStrings[3] = {"Look at me, Mike Kasprzak! I did a total clean up in these dungeon,\n I will do the same in your LD castle! Prepare yourself!",
							"And this is the end for your demons, Jaraxxus. Bow down to the light!"}

	self.maps[1].pointOfInterest = EasyLD.point:new(620,270)
	self.maps[2].pointOfInterest = EasyLD.point:new(745,505)
	self.maps[3].pointOfInterest = EasyLD.point:new(820,512)

	self.player = PushSlime:new(64, 128, EasyLD.area:new(EasyLD.circle:new(64, 128, 16)))
	self.player.depth = 0
	self.player.isPlayer = true

	self.slices = {}
	self.slices[1] = EasyLD.worldSlice:new(self.maps[1], EasyLD.point:new(0,0))
	self.slices[2] = EasyLD.worldSlice:new(self.maps[2], EasyLD.point:new(0,0))
	self.slices[3] = EasyLD.worldSlice:new(self.maps[3], EasyLD.point:new(728-160, 512-288))

	self.slices[1]:addEntity(self.player)
	self.slices[1]:addEntity(ExplodeSlime:new(128, 256, EasyLD.area:new(EasyLD.circle:new(128, 256, 16))))
	self.slices[1]:addEntity(FireSlime:new(256, 256, EasyLD.area:new(EasyLD.circle:new(256, 256, 16))))

	self.slices[2]:addEntity(FireSlime:new(64, 128, EasyLD.area:new(EasyLD.circle:new(64, 128, 16))))
	self.slices[2]:addEntity(ExplodeSlime:new(128, 256, EasyLD.area:new(EasyLD.circle:new(128, 256, 16))))
	self.slices[2]:addEntity(PushSlime:new(256, 256, EasyLD.area:new(EasyLD.circle:new(256, 256, 16))))

	self.slices[3]:addEntity(Treasure:new(736 + 128, 512, EasyLD.area:new(EasyLD.box:new(736 + 128, 512, 16, 16, EasyLD.color:new(0,255,0)))))

	self.hero = Hero:new(512, 300, EasyLD.area:new(EasyLD.circle:new(512, 300, 16, EasyLD.color:new(0, 255, 0))))
	self.hero:load(level or 0)
	self.hero:addPointOfInterest(self.maps[1].pointOfInterest)
	self.hero:speak(self.randomStrings[self.player.depth + 1][math.random(1, 2)], 3)
	self.slices[1]:addEntity(self.hero)

	DM = EasyLD.depthManager:new(self.player, self.slices[1], 1, 0, 2, 220)
	DM:addDepth(1, 0.75, self.slices[2], 220)
	DM:addDepth(2, 0.75, self.slices[3], 220)
	DM:centerOn(400, 300)
	self.DM = DM

	if gamedata == nil then
		self.floors = {1, 2, 3}
	else
		self.floors = gamedata.floors
	end

	self.nbFloors = #self.floors

	self.isNewFloor = true
	self.timeEntrance = 3
end

function GameScreen:preCalcul(dt)
	if self.isNewFloor then
		self.timeEntrance = self.timeEntrance - dt
		if self.timeEntrance <= 0 then
			self.isNewFloor = false
			return dt
		elseif self.timeEntrance > 3 then
			return dt
		elseif self.timeEntrance < 0.09 then
			return dt * (1 - self.timeEntrance)
		else
			return dt * 0.01
		end
	else
		return dt
	end
end

function GameScreen:update(dt)
	DM:update(dt)
	
	if self.player.depth + 1 == #self.slices then
		if self.hero:hasGotTreasure() then
			print("end")
		end
	elseif self.hero.isDead and not self.newScreen then
		self.newScreen = true
		EasyLD:nextScreen(GameScreen:new(self.hero.level + 1, {floors = self.floors}), "fade", nil, 2, true, "quad")
	elseif self.hero:isPointOfInterestReached(self.maps[self.player.depth + 1]) then
		self.slices[self.player.depth + 1]:removeEntity(self.hero)
		self.slices[self.player.depth + 2]:addEntity(self.hero)
		
		self.hero:addPointOfInterest(self.maps[self.player.depth + 2].pointOfInterest)
		self.hero.canAttack = true
		self.hero.choice = nil
		self.hero:isLanding()

		self.timer = EasyLD.flux.to(DM.depth[self.player.depth + 1], 2, {ratio = 1}):ease("backin")
		self.timer2 = EasyLD.flux.to(DM.depth[self.player.depth], 2, {alpha = 0})

		local oldDepth = self.player.depth
		self.player = self.slices[self.player.depth + 2].entities[1]
		self.player.isPlayer = true
		self.player.depth = oldDepth + 1
		DM:follow(self.player)

		self.hero:speak(self.randomStrings[self.player.depth + 1][math.random(1, 2)], 5)
		self.isNewFloor = true
		self.timeEntrance = 5
	end

	if EasyLD.keyboard:isPressed("space") or (self.player.isDead and #self.slices[self.player.depth + 1].entities > 1) then
		local oldId = self.player.id
		local depth = self.player.depth
		self.player.isPlayer = false
		
		local newId = oldId % #self.slices[depth+1].entities + 1
		if newId == self.hero.id then newId = newId % #self.slices[depth+1].entities + 1 end

		self.player = self.slices[depth+1].entities[newId]
		self.player.isPlayer = true
		self.player.depth = depth
		DM:follow(self.player, 0.5)
	end
end

function GameScreen:draw()
	self.DM:draw()
	--EasyLD.postfx:use("vignette", 0.6, 0.1, 0.1)
	font:print("Floors: " .. self.nbFloors, 40, EasyLD.box:new(0,0,EasyLD.window.w, 50), nil, nil, EasyLD.color:new(255,255,255))
	font:print(self.maps[self.player.depth + 1].name, 60, EasyLD.box:new(0,0,EasyLD.window.w, 50), "center", nil, EasyLD.color:new(255,255,255))
	font:print(self.hero.level.." :Heros beaten",40, EasyLD.box:new(0,0,EasyLD.window.w, 50), "right", nil, EasyLD.color:new(255,255,255))
end

function GameScreen:onEnd()

end

return GameScreen