local Window = {}

function Window:resize(W, H, flags)
	if flags == nil then
		flags = {}
	end
	
	love.window.setMode(W, H, {vsync = false, unpack(flags)})
	EasyLD.window.w = W
	EasyLD.window.h = H
end

function Window:setTitle(title)
	love.window.setTitle(title)
end

function Window:setFullscreen(bool)
	w, h, flags = love.window.getMode()
	flags.fullscreen = bool
	love.window.setMode(w, h, flags)
end

return Window