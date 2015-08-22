local class = require 'EasyLD.lib.middleclass'

local SpriteAnimation = class('SpriteAnimation')

local function _nextSprite(sAnim8)
	sAnim8.current = sAnim8.current + 1
	if sAnim8.current == sAnim8.nbImg then
		sAnim8.current = 0
		sAnim8.nbCycle = sAnim8.nbCycle - 1
		if sAnim8.nbCycle == 0 then
			sAnim8:cancel()
		end
	end
end

function SpriteAnimation.static.getTimeFromPercent(time, table)
	local t = {}
	local factor = 1
	if table[#table] > 1 then
		factor = 100
	end

	local tm = 0
	for i,v in ipairs(table) do
		t[i] = time * v / factor - tm
		tm = tm + t[i]
	end

	return t
end

function SpriteAnimation:initialize(obj, name, nbImg, time, w, h, idStart, nbCycle, imgType)
	self.obj = obj
	self.src = name
	self.nbImg = nbImg
	self.idStart = idStart or 0
	self.current = 0
	self.img = EasyLD.image:new(self.src)
	self.w = w
	self.h = h
	self.nbSpriteW = math.floor(self.img.w/self.w)
	self.time = time
	self.nbCycle = nbCycle or 1
	self.imgType = imgType
end

function SpriteAnimation:pause()
	EasyLD.timer:cancel(self.timer)
end

function SpriteAnimation:stop()
	self.nbCycle = 1
end

function SpriteAnimation:playTable()
	if self.timer ~= nil then
		self:cancel()
	end
	self.timer = {}
	local t = 0

	for i,v in ipairs(self.time) do
		t = t + v
		self.timer[i] = EasyLD.timer.after(t, _nextSprite, self)
	end

	if self.nbCycle > 1 or self.nbCycle < 0 then
		table.insert(self.timer, EasyLD.timer.after(t, self.playTable, self))
	end
end

function SpriteAnimation:cancel()
	if type(self.time) == "number" then
		EasyLD.timer.cancel(self.timer)
	else
		for _,v in ipairs(self.timer) do
			EasyLD.timer.cancel(v)
		end
	end
end

function SpriteAnimation:playNumber()
	self.timer = EasyLD.timer.every(self.time, _nextSprite, self)
end

function SpriteAnimation:play()
	self.obj.img = self
	self.obj.imgType = self.imgType
	if type(self.time) == "number" then
		self:playNumber()
	else
		self:playTable()
	end
end

function SpriteAnimation:draw(mapX, mapY, angle)
	local x = ((self.idStart + self.current) % self.nbSpriteW ) * self.w
	local y = math.floor(((self.idStart + self.current) / self.nbSpriteW )) * self.h
	self.img:drawPart(mapX, mapY, x, y, self.w, self.h, self.current, angle)
end

return SpriteAnimation