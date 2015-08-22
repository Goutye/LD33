local class = require 'EasyLD.lib.middleclass'

local Playlist = class('Playlist')

function Playlist:initialize(name, type, random)
	self.name = name
	self.type = type --Type of the stop/play fct (fading etc)
	self.list = {}
	if EasyLD.music.playlists == nil then
		EasyLD.music.playlists = {}
	end
	EasyLD.music.playlists[name] = self
	self.current = 1
	self.random =  random or false
end

function Playlist:add(music)
	table.insert(self.list, music)
end

function Playlist:remove(id)
	if id <= #self.list then
		table.remove(id)
	end
end

function Playlist:play(str)
	if self.list[self.current].timer ~= nil then
		EasyLD.timer.cancel(self.list[self.current].timer)
	end

	self.list[self.current]:stop()

	if self.random then
		if #self.list < 2 then
			self.list[self.current]:stop()
		else
			local x = self.current
			while x == self.current do
				x = math.random(1, #self.list)
			end
			self.current = x
		end
	elseif str == "next" then
		self.current = self.current % #self.list + 1
	end

	local fct = function () 
					self:play("next")
				end

	self.list[self.current]:play(fct)
end

function Playlist:stop()
	self.list[self.current]:stop()
end

return Playlist