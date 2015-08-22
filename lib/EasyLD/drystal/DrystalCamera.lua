local Camera = {}

function Camera:scale(scale)
	EasyLD.camera.scaleValue = EasyLD.camera.scaleValue + scale

	if EasyLD.camera.auto then
		EasyLD.camera:compute()
		drystal.camera.zoom = EasyLD.camera.scaleValue
	end
end

function Camera:move(dx, dy, time, ...)
	if EasyLD.camera.mode ~= "normal" then
		local tween = EasyLD.flux.to(EasyLD.camera, time or 0.8, {currentX = EasyLD.camera.currentX + dx, currentY = EasyLD.camera.currentY + dy}, ...):ease(EasyLD.camera.mode)
	else
		EasyLD.camera.currentX = EasyLD.camera.currentX + dx
		EasyLD.camera.currentY = EasyLD.camera.currentY + dy
		
		if EasyLD.camera.auto then
			EasyLD.camera:compute()
			drystal.camera.x = -(EasyLD.camera.ox + EasyLD.camera.x)
			drystal.camera.y = -(EasyLD.camera.oy + EasyLD.camera.y)
		end
	end
end

function Camera:rotate(angle, ox, oy, time, ...)
	if ox ~= nil and oy ~= nil then

	elseif Camera.follower ~= nil then

	else
		--Camera.ox Camera.oy Currently : rotation around the center of the screen
	end
	if EasyLD.camera.mode ~= "normal" then
		local tween = EasyLD.flux.to(EasyLD.camera, time or 0.8, {currentAngle = EasyLD.camera.currentAngle + angle}, ...):ease(EasyLD.camera.mode)
	else
		EasyLD.camera.currentAngle = EasyLD.camera.currentAngle + angle

		if EasyLD.camera.auto then
			EasyLD.camera:compute()
			drystal.camera.angle = -EasyLD.camera.angle
		end
	end
end

function Camera:draw(withoutShake)
	EasyLD.camera:compute(withoutShake)
	drystal.camera.zoom = EasyLD.camera.scaleValue
	drystal.camera.x = -(EasyLD.camera.ox + EasyLD.camera.x)
	drystal.camera.y = -(EasyLD.camera.oy + EasyLD.camera.y)
	drystal.camera.angle = -EasyLD.camera.angle
end

function Camera:actualize(withoutShake)
	drystal.camera.reset()
	Camera:draw(withoutShake)
end


function Camera:push()
	drystal.camera.push()
end

function Camera:pop()
	drystal.camera.pop()
end

function Camera:reset()
	drystal.camera.reset()
end

return Camera