local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local TitleScreen = class('TitleScreen', IScreen)

local TutorialScreen = require 'screens.TutorialScreen'

function TitleScreen:initialize(gamedata)
	EasyLD.camera:reset()
	self.box = EasyLD.box:new(0,0,EasyLD.window.w, EasyLD.window.h, EasyLD.color:new(0,0,0))

	self.img = EasyLD.image:new("assets/sprites/background.png")

	self.boxThank = EasyLD.box:new(0, 500, EasyLD.window.w, 100)
	self.area = EasyLD.area:new(self.boxThank)
	self.area:attach(EasyLD.point:new(EasyLD.window.w /2, 540))
	self.area:follow(self.area.forms[2])
	self.timer = EasyLD.flux.to(self.area, 2, {angle = math.pi/12}):oncomplete(function()
			self:next(-self.area.angle)
		end):ease("backout")
	music.gg:stop()
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

function TitleScreen:next(angle)
	self.timer = EasyLD.flux.to(self.area, 2, {angle = angle}):oncomplete(function()
		self:next(-self.area.angle)
	end):ease("quadinout")
end

function TitleScreen:preCalcul(dt)
	return dt
end

function TitleScreen:update(dt)
	self.PS:update(dt)
	self.PS2:update(dt)
	self.PS3:update(dt)

	if EasyLD.keyboard:isPressed("space") then
		EasyLD.screen:nextScreen(TutorialScreen:new(), "slide", {-1,0}, 2, false, "quadinout")
		--EasyLD.screen:nextScreen(TutorialScreen:new(), "cover", {0,1}, 3, false, "bounceout")
	end
end

function TitleScreen:draw()
	self.img:draw(0,0, 0)

	self.PS:draw()
	self.PS2:draw()
	self.PS3:draw()

	font:printOutLine("Empowered darkness", 100, EasyLD.box:new(0,64, EasyLD.window.w, 100), "center", nil, EasyLD.color:new(255,255,255) , EasyLD.color:new(0,0,0), 4)
	
	font:printOutLine("Because the light should get the f*** out! ", 36, EasyLD.box:new(0, 200,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)

	font:printOutLine("Press [SPACE] to play!", 40, self.boxThank, "center", nil, EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)

	font:printOutLine("A game made by Goutye", 20, EasyLD.box:new(0, 0,EasyLD.window.w, EasyLD.window.h - 20), "right", "bottom", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	font:printOutLine("You are the monster - LD33", 20, EasyLD.box:new(0, 0,EasyLD.window.w, EasyLD.window.h), "right", "bottom", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	
end

function TitleScreen:onEnd()
end

return TitleScreen