package.path = package.path .. ';src/?.lua'
package.path = package.path .. ';lib/?.lua'

require 'EasyLD'

local GameScreen = require 'screens.GameScreen'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 800
DM = {}

function EasyLD:load()

	music = {}
	music.gg = EasyLD.music:new("assets/musics/titlescreen.mp3", nil, true)
	playlist = EasyLD.playlist:new("ambiance", "fading", true)
	playlist:add(EasyLD.music:new("assets/musics/1.mp3"), nil, true)
	playlist:add(EasyLD.music:new("assets/musics/2.mp3"), nil, true)
	playlist:add(EasyLD.music:new("assets/musics/3.mp3"), nil, true)
	playlist:add(EasyLD.music:new("assets/musics/4.mp3"), nil, true)
	playlist:add(EasyLD.music:new("assets/musics/5.mp3"), nil, true)


	EasyLD.window:resize(WINDOW_WIDTH, WINDOW_HEIGHT)
	EasyLD.window:setTitle("LD33 - Goutye")
	EasyLD:nextScreen(GameScreen:new())
	font = EasyLD.font:new("assets/fonts/visitor.ttf")
end

function EasyLD:preCalcul(dt)
	-- local fps = EasyLD:getFPS()
	-- if fps ~= 0 then
	-- 	return 1/120
	-- else
	-- 	return dt
	-- end
	return dt
end

function EasyLD:update(dt)
	
end

function EasyLD:draw()
	font:print("FPS: "..EasyLD:getFPS(), 20, EasyLD.box:new(0, WINDOW_HEIGHT-50, 100, 50), nil, "bottom", EasyLD.color:new(255,255,255))
end