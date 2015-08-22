local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local Treasure = class('Treasure', Entity)

function Treasure:load()
end

function Treasure:update(dt, entities)
end

function Treasure:onDeath()

end

function Treasure:takeDmg()

end

function Treasure:onCollide(entity)
	entity.gotTresure = true
end

function Treasure:draw()
	if self.spriteAnimation ~= nil then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
	end
end

return Treasure