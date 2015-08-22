local class = require 'EasyLD.lib.middleclass'

local IScreen = class('IScreen')

function IScreen:initialize()
end

function IScreen:preCalcul(dt)
	return dt
end

function IScreen:update(dt)
end

function IScreen:draw()
end

function IScreen:onPause()
end

function IScreen:onEnd()
end

return IScreen