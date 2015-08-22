local class = require 'EasyLD.lib.middleclass'

local Music = class('Music')

function Music:initialize(name, type)
	if type == "static" then
		self.mData = love.sound.newSoundData(name)
		self.m = love.audio.newSource(self.mData)
		self.static = true
	else
		self.m = love.audio.newSource(name)
		self.static = false
	end
	self.timer = nil
	self.looping = false
	self.name = name
end

function Music:play(callback, ...)
	self.m:play()

	if callback ~= nil and not self.looping then
		if self.static then
			self.timer = EasyLD.timer.after(self:getDuration(), callback, ...)
		end
	end
end

function Music:stop()
	self.m:stop()
end

function Music:pause()
	self.m:pause()
end

function Music:rewind()
	self.m:rewind()
end

function Music:isPlaying()
	return self.m:isPlaying()
end

function Music:isPaused()
	return self.m:isPaused()
end

function Music:isStopped()
	return self.m:isStopped()
end

function Music:setCurrentTime(nbSeconds)
	self.m:seek(nbSeconds, "seconds")
end

function Music:getCurrentTime()
	return self.m:tell("seconds")
end

function Music:getDuration()
	return self.mData:getDuration()
end

function Music:setPosition(x, y, z)
	self.m:setPosition(x, y, z)
end

function Music:setDirection(x, y, z)
	self.m:setDirection(x, y, z)
end

function Music:setVelocity(x, y, z)
	self.m:setVelocity(x, y, z)
end

function Music:setLooping(bool)
	self.m:setLooping(bool)
	self.looping = bool
end

function Music:setPitch(n)
	self.m:setPitch(n)
end

function Music:setVolume(v)
	self.m:setVolume(v)
end

return Music