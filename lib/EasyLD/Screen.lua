local Screen = {}
Screen.alpha = 0
Screen.box = nil
Screen.listTransition = {}

function Screen:nextScreen(screen, transition, transitionArgs, time, pause, type)
	if EasyLD.screen.current == nil then
		EasyLD.screen.current = screen
		EasyLD.screen.box = EasyLD.box:new(0, 0, EasyLD.window.w, EasyLD.window.h, EasyLD.color:new(0,0,0,255))
	elseif not EasyLD.screen.transition then
		EasyLD.screen.transition = EasyLD.screen.listTransition[transition or "fade"]
		EasyLD.screen.transitionArgs = transitionArgs or {}
		EasyLD.screen.transitionStart = false
		EasyLD.screen.next = screen
		EasyLD.screen.nextType = type or "quad"
		EasyLD.screen.nextTime = time or 0.01
		EasyLD.screen.nextPause = pause
		EasyLD.screen.postfx = {}
	end
end

function Screen:preCalcul(dt)
	return EasyLD.screen.current:preCalcul(dt)
end

function Screen:update(dt)
	if EasyLD.screen.next ~= nil and not EasyLD.screen.transitionStart then
		local typeEase = EasyLD.screen.nextType
		if self.transition then
			self:transition("start")
			self.transitionStart = true
		else
			self:changeScreen()
		end
		if self.nextPause then
			self.current:onPause()
		end
	end
	if not EasyLD.screen.nextPause then
		EasyLD.screen.current:update(dt)
		if self.transitionStart and EasyLD.screen.next then
			EasyLD.screen.next:update(dt)
		end
	end
end

function Screen:changeScreen()
	if self.transition then
		self:transition("change")
	end
	EasyLD.screen.current:onEnd()
	EasyLD.screen.current = EasyLD.screen.next
	EasyLD.screen.next = nil
	EasyLD.screen.nextType = nil
	EasyLD.screen.nextTime = nil
	EasyLD.screen.nextPause = nil
end

function Screen:draw()
	EasyLD.screen.current:draw()
	EasyLD.camera:pushAndReset()
	EasyLD.screen.box.c.a = EasyLD.screen.alpha
	EasyLD.screen.box:draw()
	EasyLD.camera:pop()
	if EasyLD.screen.transitionStart then
		EasyLD.screen:transition("postfx")
	end
end

function Screen:addTransition(name, startFct, changeFct, postfxFct, ratio)
	local fct = function(self, state)
			if state == "start" then
				startFct(self)
				self.timer = EasyLD.timer.after(self.nextTime * ratio, function () EasyLD.screen:changeScreen() end)
			elseif state == "change" then
				changeFct(self)
				self.timer = EasyLD.timer.after(self.nextTime * (1-ratio), function () 
						EasyLD.screen.transition = false
						EasyLD.screen.timer = nil
						EasyLD.screen.transitionStart = false
					end)
			elseif state == "postfx" then
				postfxFct(self)
			end
		end
	Screen.listTransition[name] = fct
end

local function fade(self, state)
	local typeEase = EasyLD.screen.nextType
	if state == "start" then
		if EasyLD.screen.nextType ~= "linear" then
			typeEase = typeEase .. "in"
		end
		EasyLD.screen.timer = EasyLD.flux.to(EasyLD.screen, EasyLD.screen.nextTime/2, {alpha = 255}):ease(typeEase):oncomplete(function () EasyLD.screen:changeScreen() end)
	elseif state == "change" then
		if EasyLD.screen.nextType ~= "linear" then
			typeEase = typeEase .. "out"
		end
		EasyLD.screen.timer = EasyLD.flux.to(EasyLD.screen, EasyLD.screen.nextTime/2, {alpha = 0}):ease(typeEase):oncomplete(function () 
																EasyLD.screen.timer = nil
																EasyLD.screen.transition = false
																EasyLD.screen.transitionStart = false
															end)
	end
end

local function circleFade(self, state)
	local typeEase = EasyLD.screen.nextType
	if state == "start" then
		if EasyLD.screen.nextType ~= "linear" then
			typeEase = typeEase .. "out"
		end
		self.postfx = {percent = 1}
		self.timer = EasyLD.flux.to(EasyLD.screen.postfx, EasyLD.screen.nextTime/2, {percent = 0.001}):ease(typeEase):oncomplete(function () EasyLD.screen:changeScreen() end)
	elseif state == "change" then
		if EasyLD.screen.nextType ~= "linear" then
			typeEase = typeEase .. "in"
		end
		self.timer = EasyLD.flux.to(EasyLD.screen.postfx, EasyLD.screen.nextTime/2, {percent = 1}):ease(typeEase):oncomplete(function () 
																EasyLD.screen.timer = nil
																EasyLD.screen.transition = false
																EasyLD.screen.transitionStart = false
															end)
	elseif state == "postfx" then
		EasyLD.postfx:use("vignette", self.postfx.percent, math.max(1-(self.transitionArgs[1] or 0.2)-(1-(self.postfx.percent or 1)),-0.01))
	end
end

local function tilt(self, state)
	if state == "start" then
		self.postfx = {percent = 1}
		EasyLD.camera:tilt(EasyLD.vector:new(self.transitionArgs[1] or -1, self.transitionArgs[2] or 0), EasyLD.window.w, EasyLD.screen.nextTime, 1/8)
		self.timer = EasyLD.timer.after(EasyLD.screen.nextTime/8, function () EasyLD.screen:changeScreen() end)
	elseif state == "change" then
		self.timer = EasyLD.timer.after(EasyLD.screen.nextTime/8*7, function () 
																EasyLD.screen.timer = nil
																EasyLD.screen.transition = false
																EasyLD.screen.transitionStart = false
															end)
	end
end

local function slide(self, state)
	local typeEase = EasyLD.screen.nextType
	if state == "start" then
		self.postfx = {percent = 1.0, oldCamera = EasyLD.camera:getPosition()}
		
		local power = EasyLD.window.w
		if self.transitionArgs[1] == 0 then power = EasyLD.window.h end

		EasyLD.camera:tilt(EasyLD.vector:new(self.transitionArgs[1] or -1, self.transitionArgs[2] or 0), power, EasyLD.screen.nextTime, 0.999, typeEase)
		self.timer = EasyLD.flux.to(EasyLD.screen.postfx, EasyLD.screen.nextTime*0.999, {percent = 0}):ease(typeEase):oncomplete(function () EasyLD.screen:changeScreen() end)
	elseif state == "change" then
		EasyLD.screen.timer = nil
		self.timer = EasyLD.timer.after(EasyLD.screen.nextTime*0.001, function() 
					EasyLD.screen.transition = false
					EasyLD.screen.timer = nil
					EasyLD.screen.transitionStart = false
				end)
	elseif state == "postfx" then
		local offset = (EasyLD.vector:new(self.transitionArgs[1] or -1, self.transitionArgs[2] or 0) * EasyLD.vector:new(EasyLD.window.w, EasyLD.window.h))
		local offsetNextScreen = offset + self.postfx.oldCamera
		local old = EasyLD.camera:getPosition()
		EasyLD.camera:moveTo(offsetNextScreen.x, offsetNextScreen.y)
		EasyLD.camera:actualize()

		if self.next ~= nil then
			self.next:draw()
		else
			self.current:draw()
		end

		local v = offsetNextScreen - old
		v = old + v * (1-(self.postfx.percent or 1))
		EasyLD.camera:moveTo(v.x, v.y)
		EasyLD.camera:actualize()

		EasyLD.camera:moveTo(old:get())
	end
end

local function cover(self, state)
	local typeEase = EasyLD.screen.nextType
	if state == "start" then
		self.postfx = {percent = 1.0}
		self.timer = EasyLD.flux.to(EasyLD.screen.postfx, EasyLD.screen.nextTime, {percent = 0}):ease(typeEase):oncomplete(function () EasyLD.screen:changeScreen() end)
	elseif state == "change" then
		EasyLD.screen.transition = false
		EasyLD.screen.timer = nil
		EasyLD.screen.transitionStart = false
	elseif state == "postfx" then
		local offset = (EasyLD.vector:new(self.transitionArgs[1] or -1, self.transitionArgs[2] or 0) * EasyLD.vector:new(EasyLD.window.w, EasyLD.window.h))
		local old = EasyLD.camera:getPosition()
		local offsetNextScreen = offset * self.postfx.percent + old
		EasyLD.camera:moveTo(offsetNextScreen.x, offsetNextScreen.y)
		EasyLD.camera:actualize()

		self.next:draw()

		EasyLD.camera:moveTo(old:get())
		EasyLD.camera:actualize()
	end
end

local function fusion(self, state)
	local typeEase = EasyLD.screen.nextType
	if state == "start" then
		self.postfx = {percent = 0, s = EasyLD.surface:new()}
		self.timer = EasyLD.flux.to(EasyLD.screen.postfx, EasyLD.screen.nextTime, {percent = 1}):ease(typeEase):oncomplete(function () EasyLD.screen:changeScreen() end)
	elseif state == "change" then
		EasyLD.screen.transition = false
		EasyLD.screen.timer = nil
		EasyLD.screen.transitionStart = false
	elseif state == "postfx" then
		local s = self.postfx.s
		s:clear()
		s:drawOn(true)
		self.next:draw()
		EasyLD.surface:drawOnScreen()
		EasyLD.camera:moveTo(0,0)
		EasyLD.camera:actualize(true)
		EasyLD.graphics:setColor(EasyLD.color:new(255, 255, 255, self.postfx.percent * 255))
		s:draw(0,0)
		EasyLD.camera:actualize()
	end
end

Screen.listTransition["fade"] = fade
Screen.listTransition["fusion"] = fusion
Screen.listTransition["circleFade"] = circleFade
Screen.listTransition["tilt"] = tilt
Screen.listTransition["slide"] = slide
Screen.listTransition["cover"] = cover

return Screen