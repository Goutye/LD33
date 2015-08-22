local Camera = {}

Camera.scaleValue = 1
Camera.scaleValueY = nil
Camera.x = 0
Camera.y = 0
Camera.currentX = 0
Camera.currentY = 0
Camera.currentAngle = 0
Camera.dx = 0
Camera.dy = 0
Camera.ox = 0
Camera.oy = 0
Camera.shakeX = 0
Camera.shakeY = 0
Camera.shakeAngle = 0

Camera.tiltOffset = {}
Camera.tiltTimer = {}

Camera.follower = nil
Camera.angle = 0
Camera.mode = "normal"
Camera.auto = false
Camera.shakeDuration = 0

Camera.timer = {}

function Camera:setMode(mode)
	EasyLD.camera.mode = mode
end

function Camera:setAuto(bool)
	EasyLD.camera.auto = bool
end

function Camera:clean()
	EasyLD.camera.scaleValue = 1
	EasyLD.camera.scaleValueY = nil
	EasyLD.camera.currentX = 0
	EasyLD.camera.currentY = 0
	EasyLD.camera.currentAngle = 0
	EasyLD.camera.dx = 0
	EasyLD.camera.dy = 0
	EasyLD.camera.ox = 0
	EasyLD.camera.oy = 0
	EasyLD.camera.shakeX = 0
	EasyLD.camera.shakeY = 0
	EasyLD.camera.shakeAngle = 0
	EasyLD.camera.mode = "normal"
	EasyLD.camera.auto = false

	for k,v in pairs(EasyLD.camera.timer) do
		v:stop()
	end

	EasyLD.camera.timer = {}
end

function Camera:scaleTo(scale, scaleY, time, ...)
	return EasyLD.camera:scale(scale - EasyLD.camera.scaleValue, (scaleY or scale) - (Camera.scaleValueY or Camera.scaleValue), time, ...)
end

function Camera:scale(scale, scaleY)
	
end

function Camera:moveTo(x, y, time, ...)
	return EasyLD.camera:move(x - EasyLD.camera.currentX, y - EasyLD.camera.currentY, time, ...)
end

function Camera:move(x, y)

end

function Camera:rotateTo(angle, ox, oy, time, ...)
	return EasyLD.camera:rotate(angle - EasyLD.camera.currentAngle, ox, oy, time, ...)
end

function Camera:rotate(angle, ox, oy)

end

function Camera:follow(obj)
	EasyLD.camera.follower = obj
end

function Camera:update(dt)
	if EasyLD.camera.follower ~= nil then
		local f = EasyLD.camera.follower
		local mode = self.mode
		self.mode = "normal"
		self:moveTo(f.x - EasyLD.window.w/2, f.y - EasyLD.window.h/2)
		self.mode = mode
	end
	if EasyLD.camera.shakeDuration > 0 then
		EasyLD.camera.shakeDuration = EasyLD.camera.shakeDuration - dt
		EasyLD.camera:makeShake(EasyLD.camera.shakeVars)
		EasyLD.camera.currentX = EasyLD.camera.shakeOld.x
		EasyLD.camera.currentY = EasyLD.camera.shakeOld.y
		EasyLD.camera.currentAngle = EasyLD.camera.shakeOld.angle
	elseif EasyLD.camera.shakeOld ~= nil then
		local old = EasyLD.camera.shakeOld
		if old.x ~= nil then
			EasyLD.camera.shakeX = 0
		end
		if old.y ~= nil then
			EasyLD.camera.shakeY = 0
		end
		if old.angle ~= nil then
			EasyLD.camera.shakeAngle = 0
		end

		EasyLD.camera.shakeOld = nil
	end
end

function Camera:compute(withoutShake)
	EasyLD.camera.x = EasyLD.camera.currentX
	EasyLD.camera.y = EasyLD.camera.currentY
	if not withoutShake then
		EasyLD.camera.x = EasyLD.camera.x + EasyLD.camera.shakeX
		EasyLD.camera.y = EasyLD.camera.y + EasyLD.camera.shakeY
		for i,v in pairs(EasyLD.camera.tiltOffset) do
			EasyLD.camera.x = EasyLD.camera.x + v.x
			EasyLD.camera.y = EasyLD.camera.y + v.y
		end
	end
	EasyLD.camera.angle = EasyLD.camera.currentAngle + EasyLD.camera.shakeAngle
end

function Camera:getPosition(withShake)
	if withShake then
		return EasyLD.point:new(-EasyLD.camera.x, -EasyLD.camera.y)
	else
		return EasyLD.point:new(-EasyLD.camera.ox - EasyLD.camera.currentX, -EasyLD.camera.oy - EasyLD.camera.currentY)
	end
end

function Camera:shake(vars, duration, typeEase)
	EasyLD.camera.shakeVars = vars
	EasyLD.camera.shakeDuration = duration
	EasyLD.camera.shakeOld = {x = EasyLD.camera.x, y = EasyLD.camera.y, angle = EasyLD.camera.angle}
	if vars.x == nil then vars.x = 0.01 end
	if vars.y == nil then vars.y = 0.01 end
	if vars.angle == nil then vars.angle = 0.001 end
	EasyLD.camera.shakeTimer = EasyLD.flux.to(EasyLD.camera.shakeVars, duration, {x = 0, y = 0, angle = 0}):ease(typeEase or "quadin")
end

function Camera:tilt(dir, power, duration, ratioTilt, typeEase)
	dir:normalize()
	local offset = dir * (-power)
	local id = 1
	while EasyLD.camera.tiltOffset[id] ~= nil do id = id + 1 end
	EasyLD.camera.tiltOffset[id] = {x = 0, y = 0}

	EasyLD.camera.tiltTimer[id] = EasyLD.flux.to(EasyLD.camera.tiltOffset[id], (duration or 0.8)*(ratioTilt or 1/8), {x = offset.x, y = offset.y}):ease(typeEase or "quadinout"):oncomplete(function()
			EasyLD.camera.tiltTimer[id] = EasyLD.flux.to(EasyLD.camera.tiltOffset[id], (duration or 0.8)*(ratioTilt or 1/8)*(1/(ratioTilt or 1/8)-1), {x = 0, y = 0}):ease("elasticout"):oncomplete(function()
					EasyLD.camera.tiltTimer[id] = nil
					EasyLD.camera.tiltOffset[id] = nil
				end)
		end)
end

function Camera:makeShake(vars)
	if vars.x ~= nil then
		EasyLD.camera.shakeX = math.random(-vars.x, vars.x)
	end
	if vars.y ~= nil then
		EasyLD.camera.shakeY = math.random(-vars.y, vars.y)
	end
	if vars.angle ~= nil then
		EasyLD.camera.shakeAngle = (math.random() - 0.5) * vars.angle
	end
end

function Camera:pushAndReset()
	EasyLD.camera:push()
	EasyLD.camera:reset()
end

return Camera