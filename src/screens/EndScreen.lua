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

	self.img = EasyLD.image:new("assets/sprites/background.png")

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

	self.PS = EasyLD.particles:new(EasyLD.point:new(800,356), "assets/smoke.png")
	self.PS:setEmissionRate(200)
	self.PS:setLifeTime(0.1)
	self.PS:setInitialVelocity(900)
	self.PS:setInitialAcceleration(0)
	self.PS:setDuration(self.reloadTime)
	self.PS:setDirection(-math.pi, math.pi/36)
	self.PS:setColors({[0] = EasyLD.color:new(0,0,0,200),
						[0.2] = EasyLD.color:new(255,0,0,200),
						[1] = EasyLD.color:new(255,2,0,0)})
	self.PS:setSizes({[0] = 32,
						[0.2] = 36,
						[1] = 32})
	self.PS2 = EasyLD.particles:new(EasyLD.point:new(480,352), "assets/smoke.png")
	self.PS2:setEmissionRate(400)
	self.PS2:setLifeTime(0.1)
	self.PS2:setInitialVelocity(800)
	self.PS2:setInitialAcceleration(0)
	self.PS2:setDirection(0, math.pi/36)
	self.PS2:setColors({[0] = EasyLD.color:new(255,255,255,150),
						[0.02] = EasyLD.color:new(255,187,1,150),
						[1] = EasyLD.color:new(255,187,0,0)})
	self.PS2:setSizes({[0] = 48,
						[0.3] = 46,
						[1] = 16})

	self.PS3 = EasyLD.particles:new(EasyLD.point:new(638,310), "assets/smoke2.png")
	self.PS3:setEmissionRate(400)
	self.PS3:setLifeTime(0.5)
	self.PS3:setInitialVelocity(400)
	self.PS3:setInitialAcceleration(0)
	self.PS3:setDirection(-math.pi/2, math.pi/2)
	self.PS3:setColors({[0] = EasyLD.color:new(255,255,255,200),
						[1] = EasyLD.color:new(255,255,255,0)})
	self.PS3:setSizes({[0] = 32,
						[1] = 96})
	self.PS3:start()
	self.PS:start()
	self.PS2:start()
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
	self.PS:update(dt)
	self.PS2:update(dt)
	self.PS3:update(dt)
	if EasyLD.keyboard:isPressed(" ") then
		EasyLD.screen:nextScreen(TitleScreen:new(), "slide", {-1,0}, 2, false, "quadinout")
	end
end

function EndScreen:draw()
	self.img:draw(0,0, 0)

	self.PS:draw()
	self.PS2:draw()
	self.PS3:draw()

	font:printOutLine("You've been defeated by...", 64, EasyLD.box:new(0,0,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	font:printOutLine(self.lastHero.name, 100, EasyLD.box:new(0,64, EasyLD.window.w, 100), "center", nil, EasyLD.color:new(255,255,255) , EasyLD.color:new(0,0,0), 4)
	
	font:printOutLine("...and has taken your " .. self.money .. " pieces of gold.", 36, EasyLD.box:new(0, 200,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	if self.lastHero.firstname == "Moon" and self.lastHero.lastname == "Moon" then
		font:printOutLine("God dammit Moon Moon!", 36, EasyLD.box:new(0, 240,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	elseif self.lastHero.firstname == "Mike" and self.lastHero.lastname == "Kasprzak" then
		font:printOutLine("\"  Thank you for supporting me with these golds \nin my wild ambition of running Ludum Dare full time!\"", 25, EasyLD.box:new(0, 240,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	end

	font:printOutLine("Heroes defeated: " .. #self.heroesDefeated, 20, EasyLD.box:new(10, 230, 200, 20), nil, nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	font:printOutLine(self.strHeroes, 16, EasyLD.box:new(10, 260, 200, 600), nil, nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)

	font:printOutLine("Floors unlocked: " .. #self.floors, 20, EasyLD.box:new(0, 230, EasyLD.window.w - 10, 20), "right", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	font:printOutLine(self.strFloors, 16, EasyLD.box:new(0, 260, EasyLD.window.w - 10, 20), "right", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)

	font:printOutLine("Thank you for playing!", 40, self.boxThank, "center", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
end

function EndScreen:onEnd()

end

return EndScreen