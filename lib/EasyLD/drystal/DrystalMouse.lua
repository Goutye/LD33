local Mouse = {}

function Mouse.getPosition()
	local m = EasyLD.point:new(EasyLD.mouse.x, EasyLD.mouse.y)
	m:rotate(EasyLD.camera.angle, EasyLD.window.w/2, EasyLD.window.h/2)
	return EasyLD.point:new(drystal.screen2scene(EasyLD.mouse.x, EasyLD.mouse.y)) --m - EasyLD.camera:getPosition()
end

function drystal.mouse_press(x, y, button)
	EasyLD.mouse:buttonPressed(x,y, button)
end

function drystal.mouse_release(x, y, button)
	EasyLD.mouse:buttonReleased(x,y, button)
end

function drystal.mouse_motion(x, y, dx, dy)
	EasyLD.mouse.x = x
	EasyLD.mouse.y = y
end

EasyLD.mouse.x = 0
EasyLD.mouse.y = 0



return Mouse