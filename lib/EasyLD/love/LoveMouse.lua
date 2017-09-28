local Mouse = {}

function Mouse.getPosition()
	local m = EasyLD.point:new(love.mouse.getPosition())
	local offset = EasyLD.point:new(EasyLD.window.w/2, EasyLD.window.h/2)
	local zoom = EasyLD.point:new(EasyLD.camera.scaleValue, EasyLD.camera.scaleValueY or EasyLD.camera.scaleValue)
	m = m - offset
	m:rotate(EasyLD.camera.angle, 0, 0)
	local posZoomed = EasyLD.camera:getPosition(true)
	posZoomed.x, posZoomed.y = posZoomed.x * zoom.x, posZoomed.y * zoom.y
	m = m - posZoomed
	m = m / zoom
	return m + offset
end

function love.mousepressed( x, y, button, istouch )
    EasyLD.mouse:buttonPressed(x,y,button)
end

function love.mousereleased( x, y, button, istouch )
    EasyLD.mouse:buttonReleased(x,y,button)
end

return Mouse