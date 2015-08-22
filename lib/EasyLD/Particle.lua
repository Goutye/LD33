local class = require 'EasyLD.lib.middleclass'

local Particle = class('Particle')

function Particle:follow(obj)
	self.follower = obj
end

function Particle:setDuration(time)
	self.duration = time
end

function Particle:setEmissionRateEasing(tab, ease)
	local t = {}
	if type(ease) == "string" then
		for i,v in pairs(tab) do
			table.insert(t, ease)
		end
		ease = t
	end
	self.easeType = ease
	self.emissionTable = tab
end

function Particle:startEmissionEasing()
	local timer
	local prev = 0
	local nbTransition = 1
	local keyTable = {}
	for i,v in pairs(self.emissionTable) do
		j = 1
		while j <= #keyTable and i >= keyTable[j] do j = j + 1 end
		for k = #keyTable, j, -1 do
			keyTable[k+1] = keyTable[k]
		end
		keyTable[j] = i
	end

	if type(self.easeType) == "table" and #self.easeType >= #table - 1 then
		for k,value in ipairs(keyTable) do
			i = value
			v = self.emissionTable[i]
			if i == 0 then
				self:setEmissionRate(v)
			else
				if self:getEmissionRate() == v then
					v = v + 0.1
				end
				if timer == nil then
					timer = EasyLD.flux.to(self, (i - prev) * self.duration, {rate = v}):ease(self.easeType[nbTransition]):onupdate(function() self:setEmissionRate(self.rate) end)
				else
					timer = timer:after((i - prev) * self.duration, {rate = v}):ease(self.easeType[nbTransition]):onupdate(function() self:setEmissionRate(self.rate) end)
				end
				prev = i
				nbTransition = nbTransition + 1
			end
		end
		self.timerEmission = timer
	end
	timer:oncomplete(function() self:stop() end)
end

function Particle:setTimedEmit(time)
	self.tableEmit = time
end

function Particle:startTimedEmit()
	local timer = {}

	for i,v in pairs(self.tableEmit) do
		if i == 0 then
			self:emit(v)
		else
			table.insert(timer, EasyLD.timer.after(i * self.duration, function() 
					self:emit(v)
				end))
		end
	end
	self.timerEmit = timer
end

function Particle:stopTimer()
	for i,v in ipairs(self.timerEmit or {}) do
		EasyLD.timer.cancel(v)
	end
	self.timerEdit = nil

	if self.timerEmission then
		self.timerEmission:stop()
		self.timerEmission = nil
		EasyLD.flux.clear(self, {rate = "rate"})
	end
end

return Particle