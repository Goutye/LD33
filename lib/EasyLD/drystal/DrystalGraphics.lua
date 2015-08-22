local DrystalGraphics = {}

function DrystalGraphics:rectangle(mode, box, color)
	drystal.set_color(color.r, color.g, color.b)
	drystal.set_alpha(color.a)

	if mode == "fill" then
		drystal.draw_rect(box.x, box.y, box.w, box.h)
	else
		drystal.draw_square(box.x, box.y, box.w, box.h)
	end

	drystal.set_color(255,255,255)
	drystal.set_alpha(255)
end

function DrystalGraphics:circle(mode, circle, nbSeg, color)
	drystal.set_color(color.r, color.g, color.b)
	drystal.set_alpha(color.a)
	
	if mode == "fill" then
		drystal.draw_circle(circle.x, circle.y, circle.r)
	else
		local t = {}
		local anglePart = math.pi*2/nbSeg
		local angle = 0
		for i = 1, nbSeg do
			table.insert(t, circle.x + circle.r * math.cos(angle))
			table.insert(t, circle.y + circle.r * math.sin(angle))
			angle = angle + anglePart
		end

		drystal.draw_polyline(unpack(t), unpack(t))
	end

	drystal.set_color(255,255,255)
	drystal.set_alpha(255)
end

function DrystalGraphics:polygon(mode, color, ...)
	local p = {}
	drystal.set_color(color.r, color.g, color.b)
	drystal.set_alpha(color.a)
	
	for i,v in ipairs({...}) do
		table.insert(p, v.x)
		table.insert(p, v.y)
	end

	if mode == "fill" then
		drystal.draw_polygon(unpack(p))
	else
		drystal.draw_polyline(unpack(p), unpack(p))
	end

	drystal.set_color(255,255,255)
	drystal.set_alpha(255)
end

function DrystalGraphics:point(p, color)
	drystal.set_color(color.r, color.g, color.b)
	drystal.set_alpha(color.a)

	drystal.draw_point(p.x, p.y, 1)

	drystal.set_color(255,255,255)
	drystal.set_alpha(255)
end

function DrystalGraphics:line(p1, p2, color)
	drystal.set_color(color.r, color.g, color.b)
	drystal.set_alpha(color.a)

	drystal.draw_line(p1.x, p1.y, p2.x, p2.y)

	drystal.set_color(255,255,255)
	drystal.set_alpha(255)
end

function DrystalGraphics:triangle(mode, p1, p2, p3, color)
	DrystalGraphics:polygon(mode, color, p1, p2, p3)
end

function DrystalGraphics:setColor(color)
	color = color or EasyLD.color:new(255,255,255)
	drystal.set_color(color.r, color.g, color.b)
	drystal.set_alpha(color.a)
end

return DrystalGraphics