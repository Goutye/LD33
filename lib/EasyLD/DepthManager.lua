local class = require 'EasyLD.lib.middleclass'

local DepthManager = class('DepthManager')

function DepthManager:initialize(follower, slice, ratio, before, after, alpha)
	self.depth = {}
	local surface = EasyLD.surface:new()
	self.depth[0] = {s = surface, slice = slice, ratio = ratio or 1, offset = EasyLD.point:new(0,0), alpha = alpha or 255}
	self.nbBefore = before
	self.nbAfter = after
	self.follower = follower -- ENTITY
	self.pos = EasyLD.point:new(follower.x, follower.y)
	self.center = EasyLD.point:new(0,0)
	self.timer2 = nil
end

function DepthManager:follow(obj, mode, time, typeEase)
	if mode == nil then
		self.follower = obj
	else
		self.pos = EasyLD.point:new(self.follower.pos.x, self.follower.pos.y)
		self.follower = obj
		if self.timer2 ~= nil then
			self.timer2:stop()
		end
		self.timer2 = EasyLD.flux.to(self.pos, time or 0.8, {x = self.follower.pos, y = self.follower.pos}, "follower"):ease(typeEase or "quadout"):oncomplete(function()  
														self.timer2 = nil
													end)
	end
end

function DepthManager:centerOn(x, y, mode, time, typeEase)
	if mode == nil then
		self.center = EasyLD.point:new(x, y)
	else
		if self.timer ~= nil then
			self.timer:stop()
		end
		self.timer = EasyLD.flux.to(self.center, time or 0.8, {x = x, y = y}):ease(typeEase or "quadout"):oncomplete(function ()
																					self.timer = nil
																				end)
	end
end

function DepthManager:addDepth(id, ratio, slice, alpha)
	local surface = EasyLD.surface:new()
	self.depth[id] = {s = surface, slice = slice, ratio = ratio, offset = EasyLD.point:new(0,0), alpha = alpha or 255}
end

function DepthManager:update(dt)
	local offset
	if self.timer2 ~= nil then
		offset = EasyLD.point:new(self.pos.x, self.pos.y) - self.center
	else
		if self.follower.depth ~= nil then
			local difference = self.follower.depth - math.floor(self.follower.depth)
			local depthZoom
			if difference ~= 0 then
				if self.follower.depth > self.nbAfter then
					self.follower.depth = self.nbAfter
				elseif self.follower.depth < self.nbBefore then
					self.follower.depth = self.nbBefore
				end
				local lowScale, highScale = self.depth[math.floor(self.follower.depth)].ratio, self.depth[math.ceil(self.follower.depth)].ratio
				local diffScale = highScale - lowScale
				depthZoom = 1/ (lowScale + diffScale * difference)
			else
				depthZoom = 1/self.depth[math.floor(self.follower.depth)].ratio
			end
			offset = EasyLD.point:new(self.follower.pos.x * depthZoom, self.follower.pos.y * depthZoom) - self.center
		else
			offset = EasyLD.point:new(self.follower.pos.x, self.follower.pos.y) - self.center
		end
	end

	for i = self.nbAfter, -self.nbBefore, -1 do
		self.depth[i].offset = offset * self.depth[i].ratio
		self.depth[i].slice:update(dt)
	end
end

function DepthManager:moveUp()
	for id = -self.nbBefore, self.nbAfter - 1 do
		self.depth[id] = self.depth[id+1]
	end
end

function DepthManager:setAlpha(depth, alpha)
	self.depth[depth].alpha = alpha
end

function DepthManager:draw(noScale)
	for i = self.nbAfter, -self.nbBefore, -1 do
		local pos = self.depth[i].offset + self.center - EasyLD.point:new(EasyLD.window.w/2, EasyLD.window.h/2)
		pos.x, pos.y = math.floor(pos.x+0.5), math.floor(pos.y+0.5)

		self.depth[i].s:drawOn(true)
		EasyLD.camera:moveTo(pos.x, pos.y)
		if not noScale then EasyLD.camera:scaleTo(self.depth[i].ratio) end
		EasyLD.camera:actualize()
		self.depth[i].slice:draw()

		EasyLD.camera:scaleTo(1)
		EasyLD.camera:moveTo(0,0)
		EasyLD.camera:actualize(true)
		EasyLD.graphics:setColor(EasyLD.color:new(255,255,255,self.depth[i].alpha))
		EasyLD.surface.drawOnScreen()
		self.depth[i].s:draw(0, 0, 0, 0, self.depth[i].s.w, self.depth[i].s.h, 0)
		EasyLD.camera:actualize()
	end
end

function DepthManager:getMousePos()
	local mouse = EasyLD.mouse:getPosition()
	local pos = self.depth[self.follower.depth].offset + self.center - EasyLD.point:new(EasyLD.window.w/2, EasyLD.window.h/2)
		pos.x, pos.y = math.floor(pos.x+0.5), math.floor(pos.y+0.5)

	return mouse + pos
end

return DepthManager