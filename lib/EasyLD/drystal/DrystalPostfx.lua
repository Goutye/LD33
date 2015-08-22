local Postfx = {}

function Postfx:add(name, code, uniforms)
	return drystal.add_postfx(name, code, uniforms)
end

function Postfx:use(name, ...)
	drystal.postfx(name, ...)
end

return Postfx