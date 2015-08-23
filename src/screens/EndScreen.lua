local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local EndScreen = class('EndScreen', IScreen)

function EndScreen:initialize(gamedata)
	self.floors = gamedata.floors
	self.mapsName = {}
	self.mapsName[1] = "The entrance"
	self.mapsName[2] = "The foundry"
	self.mapsName[3] = "Pillars of Arraks"
	self.mapsName[4] = "The secret corridor"
	self.mapsName[5] = "The Ratking's\n laboratory"
	self.mapsName[6] = "Treasure Halls"
	self.heroesDefeated = gamedata.heroesDefeated
	self.money = gamedata.money
	self.lastHero = gamedata.lastHero
	EasyLD.camera:reset()
	self.box = EasyLD.box:new(0,0,EasyLD.window.w, EasyLD.window.h, EasyLD.color:new(0,0,0))

	self.strHeroes = ""
	for k,e in ipairs(self.heroesDefeated) do
		self.strHeroes = self.strHeroes .. e.name .. ": " .. e.money .. " gold\n"
	end

	self.strFloors = ""
	for i = 1, #self.floors do
		if i == #self.floors then
			self.strFloors = self.strFloors .. self.mapsName[6] .."\n"
			break
		end
		self.strFloors = self.strFloors .. self.mapsName[i] .."\n"
	end

	self.boxThank = EasyLD.box:new(0, 500, EasyLD.window.w, 100)
	self.area = EasyLD.area:new(self.boxThank)
	self.area:attach(EasyLD.point:new(EasyLD.window.w /2, 540))
	self.area:follow(self.area.forms[2])
	self.timer = EasyLD.flux.to(self.area, 2, {angle = math.pi/12}):oncomplete(function()
			self:next(-self.area.angle)
		end):ease("backout")
	music.gg:play()
end

function EndScreen:next(angle)
	self.timer = EasyLD.flux.to(self.area, 2, {angle = angle}):oncomplete(function()
		self:next(-self.area.angle)
	end):ease("quadinout")
end

function EndScreen:preCalcul(dt)
	return dt
end

function EndScreen:update(dt)
	
end

function EndScreen:draw()
	self.box:draw("fill")

	--self.maps[1]:draw(0, 0, 5, 5, 0, 0)

	font:print("You've been defeated by...", 64, EasyLD.box:new(0,0,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255))
	font:print(self.lastHero.name, 100, EasyLD.box:new(0,64, EasyLD.window.w, 100), "center", nil, EasyLD.color:new(255,255,255))
	
	font:print("...and has taken your " .. self.money .. " pieces of gold.", 36, EasyLD.box:new(0, 200,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255))
	if self.lastHero.firstname == "Moon" and self.lastHero.lastname == "Moon" then
		font:print("God dammit Moon Moon!", 36, EasyLD.box:new(0, 240,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255))
	elseif self.lastHero.firstname == "Mike" and self.lastHero.lastname == "Kasprzak" then
		font:print("\"  Thank you for supporting me with these golds \nin my wild ambition of running Ludum Dare full time!\"", 25, EasyLD.box:new(0, 240,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255))
	end

	font:print("Heroes defeated: " .. #self.heroesDefeated, 20, EasyLD.box:new(10, 230, 200, 20))
	font:print(self.strHeroes, 16, EasyLD.box:new(10, 260, 200, 600), nil, nil, EasyLD.color:new(255,255,255))

	font:print("Floors unlocked: " .. #self.floors, 20, EasyLD.box:new(0, 230, EasyLD.window.w - 10, 20), "right")
	font:print(self.strFloors, 16, EasyLD.box:new(0, 260, EasyLD.window.w - 10, 20), "right", nil, EasyLD.color:new(255,255,255))

	font:print("Thank you for playing!", 40, self.boxThank, "center", nil, EasyLD.color:new(255,255,255))
end

function EndScreen:onEnd()
	music.gg:pause()
end

return EndScreen