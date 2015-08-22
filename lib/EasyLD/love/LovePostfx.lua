local Postfx = {}

Postfx.list = {}

function Postfx:add(name, code, uniforms)
	uniforms = uniforms or {}
	local uniformsCode = ''
	for i, name in ipairs(uniforms) do
		uniformsCode = uniformsCode .. [[
uniform float ]] .. name .. [[;
		
]]
	end

	code, nb = string.gsub(code, "vec3 effect.", "vec3 effectVec3(")
	if nb == 0 then
		code, nb = string.gsub(code, "vec3 effect .", "vec3 effectVec3(")
		if nb == 0 then
			print("Error loading the effect function of shader.")
		end
	end

	local code = code .. [[

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	return vec4(effectVec3(texture, texture_coords), 1.0);
}
]]
	self.list[name] = {love.graphics.newShader(uniformsCode .. code), uniforms, love.graphics.newCanvas()}
end

function Postfx:use(name, ...)
	local s = EasyLD.postfx.list[name]

	if s == nil then
		print("Postfx not found")
		return
	end

	local sOld = love.graphics.getShader()
	s[3]:clear()
	
	love.graphics.setCanvas(s[3])
	love.graphics.setShader(s[1])
	EasyLD.camera:push()
	EasyLD.camera:reset()
	
	local uniforms = {...}
	for i,v in ipairs(uniforms) do
		s[1]:send(s[2][i], v)
	end

	local b = love.graphics.getBlendMode()
	love.graphics.setBlendMode('premultiplied')
	love.graphics.draw(love.screen, 0, 0)
	love.graphics.setBlendMode(b)
	love.graphics.setShader(sOld)

	EasyLD.camera:pop()

	local tmp = love.screen
	love.screen = s[3]
	s[3] = tmp
end

Postfx:add('gray', [[
	vec3 effect(sampler2D tex, vec2 coord)
	{
		vec3 texval = texture2D(tex, coord).rgb;
		return mix(texval, vec3((texval.r + texval.g + texval.b) / 3.0), scale);
	}
]], {'scale'})

Postfx:add('multiply', [[
	vec3 effect(sampler2D tex, vec2 coord)
	{
		vec3 texval = texture2D(tex, coord).rgb;
		return vec3(r, g, b) * texval;
	}
]], {'r', 'g', 'b'})

Postfx:add('distortion', [[
	#define pi ]] .. math.pi .. [[

	vec3 effect(sampler2D tex, vec2 coord)
	{
		vec2 c = coord;
		c.x += sin(coord.y * 8.*pi + time * 2. * pi * .75) * powerx / love_ScreenSize.x;
		c.y += sin(coord.x * 8.*pi + time * 2. * pi * .75) * powery / love_ScreenSize.y;
		return texture2D(tex, c).rgb;
	}
]], {'time', 'powerx', 'powery'})

Postfx:add('blurDir', [[
	const float weight1 = 0.3989422804014327;
	const float weight2 = 0.24197072451914536;
	const float weight3 = 0.05399096651318985;
	const float weight4 = 0.004431848411938341;
	vec3 effect(sampler2D tex, vec2 coord)
	{
		vec2 dir = vec2(dx, dy) / love_ScreenSize.xy;
		vec3 acc = vec3(0., 0., 0.);
		acc += texture2D(tex, coord).rgb * weight1;
		acc += texture2D(tex, coord + dir).rgb * weight2;
		acc += texture2D(tex, coord - dir).rgb * weight2;
		acc += texture2D(tex, coord + dir*2.).rgb * weight3;
		acc += texture2D(tex, coord - dir*2.).rgb * weight3;
		acc += texture2D(tex, coord + dir*3.).rgb * weight4;
		acc += texture2D(tex, coord - dir*3.).rgb * weight4;
		acc /= weight1 + (weight2 + weight3 + weight4) * 2.;
		return acc;
	}
]], {'dx', 'dy',})

Postfx:add('vignette', [[
	vec3 effect(sampler2D tex, vec2 coord)
	{
		vec2 m = vec2(0.5, 0.5);
		float d = distance(m, coord);
		vec3 texval = texture2D(tex, coord).rgb;
		return texval * smoothstep(outer, inner, d);
	}
]], {'outer', 'inner',})

Postfx:add('pixelate', [[
	vec3 effect(sampler2D tex, vec2 coord) {
		vec2 size = vec2(sizex, sizey) / love_ScreenSize.xy;
		vec2 c = size * floor(coord/size);
		return texture2D(tex, c).rgb;
	}
]], {'sizex', 'sizey'})

return Postfx