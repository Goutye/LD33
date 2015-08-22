local class = require 'EasyLD.lib.middleclass'

local Shader = class('Shader')

function Shader.static:useDefault()
	drystal.use_default_shader()
end

function Shader:initialize(code, vertexCode)

end

function Shader:use()
	self.s:use()
end

return Shader