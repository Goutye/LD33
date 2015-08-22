local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local Player = class('Player', Entity)

function Player:update(dt)
	local ACCELERATION = 1000

	self.acceleration = EasyLD.point:new(0, 0)

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
end

function Player:onDeath()

end

function Player:onCollide(entity)

end

return Player