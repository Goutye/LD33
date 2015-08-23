package.path = package.path .. ';src/?.lua'
package.path = package.path .. ';lib/?.lua'

require 'EasyLD'

local GameScreen = require 'screens.GameScreen'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 800

function EasyLD:load()
	EasyLD.window:resize(WINDOW_WIDTH, WINDOW_HEIGHT)
	EasyLD.window:setTitle("LD33 - Goutye")
	EasyLD:nextScreen(GameScreen:new())
	font = EasyLD.font:new("assets/fonts/visitor.ttf")
end

function EasyLD:preCalcul(dt)
	local fps = EasyLD:getFPS()
	if fps ~= 0 then
		return 1/120
	else
		return dt
	end
end

function EasyLD:update(dt)
	
end

function EasyLD:draw()
	font:print("FPS: "..EasyLD:getFPS(), 20, EasyLD.box:new(0, WINDOW_HEIGHT-50, 100, 50), nil, "bottom", EasyLD.color:new(255,255,255))
end