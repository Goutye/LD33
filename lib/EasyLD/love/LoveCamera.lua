local Camera = {}

function Camera:scale(scale, scaleY, time, ...)
	if EasyLD.camera.mode ~= "normal" then
		local value = {scaleValue = EasyLD.camera.scaleValue + scale}
		if scaleY then value.scaleValueY = (EasyLD.camera.scaleValue or 1) + scaleY
			if EasyLD.camera.scaleValueY == nil then EasyLD.camera.scaleValueY = EasyLD.camera.scaleValue end
		end
		local tween = EasyLD.flux.to(EasyLD.camera, time or 0.8, value, ...):ease(EasyLD.camera.mode)
		table.insert(EasyLD.camera.timer, tween)
		return tween
	else
		EasyLD.camera.scaleValue = EasyLD.camera.scaleValue + scale

		if scaleY ~= nil then
			EasyLD.camera.scaleValueY = (EasyLD.camera.scaleValueY or 1) + scaleY
		else
			EasyLD.camera.scaleValueY = nil
		end

		if EasyLD.camera.auto then
			EasyLD.camera:compute()
			love.graphics.scale(EasyLD.camera.scaleValue, EasyLD.camera.scaleValueY or EasyLD.camera.scaleValue)
		end
	end
end

function Camera:move(dx, dy, time, ...)
	if EasyLD.camera.mode ~= "normal" then
		local tween = EasyLD.flux.to(EasyLD.camera, time or 0.8, {currentX = EasyLD.camera.currentX + dx, currentY = EasyLD.camera.currentY + dy}, ...):ease(EasyLD.camera.mode)
		table.insert(EasyLD.camera.timer, tween)
		return tween
	else
		EasyLD.camera.currentX = EasyLD.camera.currentX + dx
		EasyLD.camera.currentY = EasyLD.camera.currentY + dy

		if EasyLD.camera.auto then
			EasyLD.camera:compute()
			love.graphics.translate(-EasyLD.camera.ox - EasyLD.camera.x, -EasyLD.camera.oy - EasyLD.camera.y)
		end
	end
end

function Camera:rotate(angle, ox, oy, time, ...)
	if ox ~= nil and oy ~= nil then
		EasyLD.camera.ox = ox
		EasyLD.camera.oy = oy
	end

	if EasyLD.camera.mode ~= "normal" then
		local tween = EasyLD.flux.to(EasyLD.camera, time or 0.8, {currentAngle = EasyLD.camera.currentAngle + angle}, ...):ease(EasyLD.camera.mode)
		table.insert(EasyLD.camera.timer, tween)
		return tween
	else
		EasyLD.camera.currentAngle = EasyLD.camera.currentAngle + angle

		if EasyLD.camera.auto then
			EasyLD.camera:compute()
			love.graphics.translate(EasyLD.window.w/2, EasyLD.window.h/2)
			love.graphics.rotate(-EasyLD.camera.angle)
			love.graphics.translate(-EasyLD.window.w/2, -EasyLD.window.h/2)
		end
	end
end

function Camera:draw(withoutShake)
	EasyLD.camera:compute(withoutShake)
	EasyLD.camera.angle = EasyLD.camera.currentAngle + EasyLD.camera.shakeAngle
	love.graphics.translate(EasyLD.window.w/2, EasyLD.window.h/2)
	love.graphics.rotate(-EasyLD.camera.angle)
	love.graphics.translate(-EasyLD.window.w/2, -EasyLD.window.h/2)
	love.graphics.translate((-EasyLD.camera.ox - EasyLD.camera.x)*EasyLD.camera.scaleValue, (-EasyLD.camera.oy - EasyLD.camera.y)*EasyLD.camera.scaleValue)
	love.graphics.translate(EasyLD.window.w/2, EasyLD.window.h/2)
	love.graphics.scale(EasyLD.camera.scaleValue, EasyLD.camera.scaleValueY or EasyLD.camera.scaleValue)
	love.graphics.translate(-EasyLD.window.w/2, -EasyLD.window.h/2)
end

function Camera:actualize(withoutShake)
	love.graphics.origin()
	Camera:draw(withoutShake)
end

function Camera:push()
	love.graphics.push()
end

function Camera:pop()
	love.graphics.pop()
end

function Camera:reset()
	love.graphics.origin()
end

return Camera