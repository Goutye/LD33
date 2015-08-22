local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local GameScreen = class('GameScreen', IScreen)

local FireSlime = require 'entities.FireSlime'
local ExplodeSlime = require 'entities.ExplodeSlime'
local PushSlime = require 'entities.PushSlime'

local Treasure = require 'entities.Treasure'

local Hero = require 'entities.Hero'

function GameScreen:initialize()
	self.tl = EasyLD.tileset:new("assets/tilesets/dungeon.png", 32)

	self.maps = {}
	self.maps[1] = EasyLD.map:new("assets/maps/map1.map", self.tl)
	self.maps[2] = EasyLD.map:new("assets/maps/map2.map", self.tl)
	self.maps[3] = EasyLD.map:new("assets/maps/treasure.map", self.tl)

	self.maps[1].pointOfInterest = EasyLD.point:new(620,270)
	self.maps[2].pointOfInterest = EasyLD.point:new(736,512)
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
	self.hero:addPointOfInterest(self.maps[1].pointOfInterest)
	self.slices[1]:addEntity(self.hero)

	DM = EasyLD.depthManager:new(self.player, self.slices[1], 1, 0, 2, 220)
	DM:addDepth(1, 0.75, self.slices[2], 220)
	DM:addDepth(2, 0.75, self.slices[3], 220)
	DM:centerOn(400, 300)
	
end

function GameScreen:preCalcul(dt)
	return dt
end

function GameScreen:update(dt)
	DM:update(dt)

	if self.player.depth + 1 == #self.slices then
		if self.hero:hasGotTreasure() then
			print("end")
		end
	elseif self.hero:isPointOfInterestReached() then
		self.slices[self.player.depth + 1]:removeEntity(self.hero)
		self.slices[self.player.depth + 2]:addEntity(self.hero)
		
		self.hero:addPointOfInterest(self.maps[self.player.depth + 2].pointOfInterest)
		self.hero.canAttack = true
		self.hero.choice = nil

		self.timer = EasyLD.flux.to(DM.depth[self.player.depth + 1], 2, {ratio = 1}):ease("backin")
		self.timer2 = EasyLD.flux.to(DM.depth[self.player.depth], 2, {alpha = 0})

		oldDepth = self.player.depth
		self.player = self.slices[self.player.depth + 2].entities[1]
		self.player.isPlayer = true
		self.player.depth = oldDepth + 1
		DM:follow(self.player)
	end
end

function GameScreen:draw()
	DM:draw()
end

function GameScreen:onEnd()

end

return GameScreen