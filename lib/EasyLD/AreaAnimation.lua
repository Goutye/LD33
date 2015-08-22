local class = require 'EasyLD.lib.middleclass'
local AreaFile = require 'EasyLD.Area'

local AreaAnimation = class('AreaAnimation')

local function exploreArea(area)
	local areaList = {}
	for i,v in ipairs(area.forms) do
		if v:isInstanceOf(AreaFile) then
			table.insert(areaList, v)
			local tab = { exploreArea(v) }

			for i2,v2 in ipairs(tab) do
				table.insert(areaList, v2)
			end
		end
	end

	return unpack(areaList)
end

function AreaAnimation:initialize(pos, area, timeFrames, frames, looping, callback, args)
	self.obj = area
	self.areaList = { exploreArea(area) }
	--initPos
	local f = {}
	if type(frames) == "string" then
		f = table.load(frames .. "init")
		for i,v in ipairs(f) do
			self.areaList[i]:rotateTo(v.angle)
			self.areaList[i]:moveTo(v.x, v.y)
		end
	end
	self.initFrames = f
	--MoveTo
	area:moveTo(pos.x, pos.y)

	if type(frames) == "string" then
		self.frames = table.load(frames)
		self.timeFrames = table.load(frames .. "time")
	else
		self.frames = frames
		self.timeFrames = timeFrames
	end
	self.looping = looping
	self.frameTween = {}
	self.current = 1
	self.timer = nil

	self.callback = callback
	self.args = args
	self.shouldStop = false
end

function AreaAnimation:init(x, y)
	self.shouldStop = false
	self.current = 1
	local x, y = x or self.obj.x, y or self.obj.y
	self.obj:moveTo(0,0)
	local f = self.initFrames
	for i,v in ipairs(f) do
		self.areaList[i]:rotateTo(v.angle)
		self.areaList[i]:moveTo(v.x, v.y)
	end
	self.obj:moveTo(x,y)
end

function AreaAnimation:pause()
	for i,v in ipairs(self.frameTween) do
		v:stop()
	end
end

function AreaAnimation:stop()
	self.shouldStop = true
end

function AreaAnimation:play()
	if self.shouldStop then
		self.shouldStop = false
	elseif #self.frameTween > 0 then
		for i,v in ipairs(self.frameTween) do
			v:play()
		end
	else
		self:nextFrame()
	end
end

function AreaAnimation:nextFrame()
	if self.looping and self.current > #self.frames then
		self.current = 1
		if self.shouldStop then
			self.shouldStop = false
			return
		end
	end

	self.frameTween = {}
	local completeOk = false

	if self.current <= #self.frames then
		for i,v in ipairs(self.frames[self.current]) do
			local easeFct = "linear"
			local vars = {}
			if v.rotation ~= nil then
				vars.angle = v.rotation
			end
			if v.translation ~= nil then
				vars.x = v.translation.x
				vars.y = v.translation.y
			end

			if v.ease ~= nil then
				easeFct = v.ease
			end

			local tween = nil
			if vars.angle ~= nil or vars.x ~= nil or vars.y ~= nil then
				tween = EasyLD.flux.to(self.areaList[i], self.timeFrames[self.current], vars, "relative", "relative"):ease(easeFct)
			end

			if not completeOk and tween ~= nil then
				self.areaList[i].AreaAnimation = self
				tween:oncomplete(function(obj)
									obj.AreaAnimation:nextFrame()
								end)
				completeOk = true
			end

			table.insert(self.frameTween, tween)
		end
	else
		self.callback(unpack(self.args))
	end
	self.current = self.current + 1
end

function AreaAnimation:draw(mapX, mapY, angle)
	self.obj:draw()
end

return AreaAnimation