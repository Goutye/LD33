local DrystalFont = {}

function DrystalFont.newFont(src, size)
	return drystal.load_font(src, size/1.25 + 0.5)
end

local function _getX_Y(x, y, text, font, box, modeW, modeH)
	local w,h = font:sizeof(text)
	h = math.ceil(h * 4/3)

	if modeW == "center" then
		local dir = box.wP:copy()
		dir:normalize()
		dir = dir * w/2

		x,y = x + box.wP.x/2-dir.x, y + box.wP.y/2 -dir.y
	elseif modeW == "right" then
		local dir = box.wP:copy()
		dir:normalize()
		dir = dir * w

		x,y = x + box.wP.x - dir.x, y + box.wP.y - dir.y
	end

	if modeH == "center" then
		local dir = box.hP:copy()
		dir:normalize()
		dir = dir * h/2

		x,y = x + box.hP.x/2-dir.x, y + box.hP.y/2 -dir.y
	elseif modeH == "bottom" then
		local dir = box.hP:copy()
		dir:normalize()
		dir = dir * h

		x,y = x + box.hP.x-dir.x, y + box.hP.y -dir.y
	end

	return x,y
end

function DrystalFont.printAdapter(text, font, box, modeW, modeH, color)
	drystal.set_color(color.r, color.g, color.b)

	if box.angle ~= 0 then
		drystal.camera.push()
		drystal.camera.reset()

		local x,y = _getX_Y(box.x, box.y, text, font, box, modeW, modeH)
		local xF, yF = font:sizeof(text)

		if EasyLD.font.surface == nil then
			EasyLD.font.surface = drystal.new_surface(2048, 2048)
		end
		
		local surface = EasyLD.font.surface
		local screen = surface:draw_on()
		
		drystal.set_alpha(0)
		drystal.draw_background()
		
		drystal.set_alpha(color.a)
		font:draw(text, 0, yF/2)
		
		surface:draw_from()
		screen:draw_on()
		drystal.set_color(255,255,255)
		drystal.set_alpha(255)

		drystal.camera.pop()
		drystal.draw_sprite_rotated({x=0, y=0, w=surface.w, h=surface.h}, x, y, box.angle, 0, 0)
	else
		drystal.set_alpha(color.a)
		font:draw(text, _getX_Y(box.x, box.y, text, font, box, modeW, modeH))
	end

	drystal.set_color(255,255,255)
	drystal.set_alpha(255)
end

function DrystalFont.printOutLineAdapter(text, font, box, modeW, modeH, color, colorOut, thickness)
	text = "{outline|outr:"..colorOut.r.."|outg:"..colorOut.g.."|outb:"..colorOut.b.."|" .. text .. "}"
	DrystalFont.printAdapter(text, font, box, modeW, modeH, color)
end

function DrystalFont.sizeOfAdapter(font, str)
	return font:sizeof(str)
end

return DrystalFont