local class = require 'EasyLD.lib.middleclass'

require 'EasyLD.lib.utf8'
require 'EasyLD.lib.table_io'

EasyLD = {}
EasyLD.tileset = require 'EasyLD.Tileset'
EasyLD.map = require 'EasyLD.Map'
EasyLD.spriteAnimation = require 'EasyLD.SpriteAnimation'
EasyLD.areaAnimation = require 'EasyLD.AreaAnimation'
EasyLD.camera = require 'EasyLD.Camera'

EasyLD.matrix = require 'EasyLD.Matrix'
EasyLD.vector = require 'EasyLD.Vector'
EasyLD.collide = require 'EasyLD.Collide'

EasyLD.area = require 'EasyLD.Area'
EasyLD.polygon = require 'EasyLD.Polygon'
EasyLD.box = require 'EasyLD.Box'
EasyLD.circle = require 'EasyLD.Circle'
EasyLD.segment = require 'EasyLD.Segment'
EasyLD.point = require 'EasyLD.Point'

EasyLD.color = require 'EasyLD.Color'
EasyLD.font = require 'EasyLD.Font'
EasyLD.printTimed = require 'EasyLD.PrintTimed'

EasyLD.playlist = require 'EasyLD.Playlist'

EasyLD.mouse = require 'EasyLD.Mouse'
EasyLD.keyboard = require 'EasyLD.Keyboard'

EasyLD.inputText = require 'EasyLD.InputText'
EasyLD.timer = require 'EasyLD.lib.cron'
EasyLD.flux = require 'EasyLD.lib.flux'

EasyLD.depthManager = require 'EasyLD.DepthManager'
EasyLD.worldSlice = require 'EasyLD.WorldSlice'
EasyLD.screen = require 'EasyLD.Screen'
EasyLD.nextScreen = EasyLD.screen.nextScreen

local function loadAdapterImage(base)
	EasyLD.image = base
end

local function loadAdapterGraphics(base)
	EasyLD.graphics = base
end

local function loadAdapterMouse(base)
	EasyLD.mouse.getPosition = base.getPosition
end

local function loadAdapterFont(base)
	EasyLD.font.newFont = base.newFont
	EasyLD.font.printAdapter = base.printAdapter
	EasyLD.font.printOutLineAdapter = base.printOutLineAdapter
	EasyLD.font.sizeOfAdapter = base.sizeOfAdapter
end

local function loadAdapterWindow(base)
	EasyLD.window = base
end

local function loadAdapterCamera(base)
	EasyLD.camera.scale = base.scale
	EasyLD.camera.move = base.move
	EasyLD.camera.rotate = base.rotate
	EasyLD.camera.draw = base.draw
	EasyLD.camera.actualize = base.actualize
	EasyLD.camera.reset = base.reset
	EasyLD.camera.push = base.push
	EasyLD.camera.pop = base.pop
end

local function loadAdapterMusic(base)
	EasyLD.music = base
end

local function loadAdapterSFX(base)
	EasyLD.sfx = base
end

local function loadAdapterSurface(base)
	EasyLD.surface = base
end

local function loadAdapterPostfx(base)
	EasyLD.postfx = base
end

local function loadAdapterShader(base)
	EasyLD.shader = base
end

local function loadAdapterParticles(base)
	EasyLD.particles = base
end

local function loadAPI(name)
	if name == "Drystal" then
		drystal = require 'drystal'
		require 'EasyLD.drystal.DrystalMain'
		require 'EasyLD.drystal.DrystalKeyboard'
		loadAdapterMouse(require 'EasyLD.drystal.DrystalMouse')
		loadAdapterGraphics(require 'EasyLD.drystal.DrystalGraphics')
		loadAdapterImage(require 'EasyLD.drystal.DrystalImage')
		loadAdapterFont(require 'EasyLD.drystal.DrystalFont')
		loadAdapterMusic(require 'EasyLD.drystal.DrystalMusic')
		loadAdapterSFX(require 'EasyLD.drystal.DrystalSFX')
		loadAdapterWindow(require 'EasyLD.drystal.DrystalWindow')
		loadAdapterCamera(require 'EasyLD.drystal.DrystalCamera')
		loadAdapterSurface(require 'EasyLD.drystal.DrystalSurface')
		loadAdapterShader(require 'EasyLD.drystal.DrystalShader')
		loadAdapterParticles(require 'EasyLD.drystal.DrystalParticle')
	elseif name == "Löve2D" then
		require 'EasyLD.love.LoveMain'
		require 'EasyLD.love.LoveKeyboard'
		loadAdapterMouse(require 'EasyLD.love.LoveMouse')
		loadAdapterGraphics(require 'EasyLD.love.LoveGraphics')
		loadAdapterImage(require 'EasyLD.love.LoveImage')
		loadAdapterFont(require 'EasyLD.love.LoveFont')
		loadAdapterMusic(require 'EasyLD.love.LoveMusic')
		loadAdapterSFX(require 'EasyLD.love.LoveSFX')
		loadAdapterWindow(require 'EasyLD.love.LoveWindow')
		loadAdapterCamera(require 'EasyLD.love.LoveCamera')
		loadAdapterSurface(require 'EasyLD.love.LoveSurface')
		loadAdapterShader(require 'EasyLD.love.LoveShader')
		loadAdapterParticles(require 'EasyLD.love.LoveParticle')
	end
end

function EasyLD:postLoad(name)
	if name == "Drystal" then
		loadAdapterPostfx(require 'EasyLD.drystal.DrystalPostfx')
	elseif name == "Löve2D" then
		loadAdapterPostfx(require 'EasyLD.love.LovePostfx')
	end
end

function EasyLD:preCalcul(dt)
	return dt
end

function EasyLD:preCalculScreen(dt)
	if EasyLD.screen.current then
		return EasyLD.screen:preCalcul(dt)
	else
		return dt
	end
end

if love ~= nil then
	loadAPI("Löve2D")
else
	loadAPI("Drystal")
end

local fpsCount = 0
local fps = 0
local fpsTimer = nil

function EasyLD:updateComponents(dt)
	fpsCount = fpsCount + 1
	EasyLD.keyboard:reset()
	EasyLD.mouse:reset()
	EasyLD.timer.update(dt)
	EasyLD.flux.update(dt)
	EasyLD.camera:update(dt)
end

function string:split(delimiter)
	local result = { }
	local from = 1
	local delim_from, delim_to = string.find( self, delimiter, from)
	while delim_from do
		table.insert(result, string.sub(self, from , delim_from-1))
		from = delim_to + 1
		delim_from, delim_to = string.find(self, delimiter, from)
	end
	table.insert(result, string.sub( self, from ))
	return result
end

function EasyLD:getFPS()
	if fpsTimer == nil then
		fpsTimer = EasyLD.timer.every(1, function() fps, fpsCount = fpsCount, 0 end)
	end
	return fps
end

return EasyLD