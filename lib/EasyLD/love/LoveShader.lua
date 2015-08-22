local class = require 'EasyLD.lib.middleclass'

local Shader = class('Shader')

function Shader.static:useDefault()
	love.graphics.setShader()
end

function Shader:initialize(code, vertexCode)

end

function Shader:use()
	love.graphics.setShader(self.s)
end

return Shader