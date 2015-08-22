local Window = {}

function Window:resize(W, H)
	drystal.resize(W, H)
	drystal.boxBackground.w = W
	drystal.boxBackground.h = H
	EasyLD.window.w = W
	EasyLD.window.h = H
end

function Window:setTitle(title)
	drystal.set_title(title)
end

function Window:setFullscreen(bool)
	drystal.set_fullscreen(bool)
end

return Window