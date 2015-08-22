local class = require 'EasyLD.lib.middleclass'

local SFX = class('SFX')

function SFX:initialize(name, volume, position, callback)
	self.mData = love.sound.newSoundData(name)
	self.m = love.audio.newSource(self.mData)
	self.timer = nil
	self.name = name
	self.m:setVolume(volume or 1)
	self.callback = callback
end

function SFX:play(callback, ...)
	self.m:stop()
	self.m:play()
	if self.callback then
		self.timer = EasyLD.timer.after(self:getDuration(), callback, ...)
	end
end

function SFX:stop()
	self.m:stop()
end

function SFX:getDuration()
	return self.mData:getDuration()
end

function SFX:setVolume(v)
	self.m:setVolume(v)
end

return SFX