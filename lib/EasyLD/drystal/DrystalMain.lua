function drystal.init()
	EasyLD:load()
end

function drystal.update(dt)
	dt = EasyLD:preCalcul(dt)
	dt = EasyLD:preCalculScreen(dt)
	if EasyLD.screen.current then
		EasyLD.screen:update(dt)
	end
	EasyLD:update(dt)
	EasyLD:updateComponents(dt)
end

drystal.boxBackground = EasyLD.box:new(0,0, 2, 2, EasyLD.color:new(0,0,0), "fill")

function drystal.draw()
	EasyLD.camera:draw()
	drystal.set_color(0,0,0)
	drystal.draw_background()
	--drystal.boxBackground:draw()
	if EasyLD.screen.current then
		EasyLD.screen:draw()
	end
	EasyLD:draw()
end
