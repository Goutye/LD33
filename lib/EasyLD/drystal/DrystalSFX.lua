local class = require 'EasyLD.lib.middleclass'

local SFX = class('SFX')

function SFX:initialize(name, volume, position, pitch)
	self.m = drystal.load_sound(name)
	self.volume = volume or 1
	self.position = position or {x = 0, y = 0}
	self.pitch = pitch or 1
end

function SFX:play(volume, position, pitch)
	if position == nil then
		position = self.position
	end
	self.m:play(volume or self.volume, position.x, position.y, pitch or self.pitch)
end

function SFX:stop()
	self.m:stop()
end

function SFX:setVolume(v)
	self.volume = v
end

function SFX:setPitch(v)
	self.pitch = v
end

function SFX:setPosition(pos)
	self.position = pos
end

return SFX