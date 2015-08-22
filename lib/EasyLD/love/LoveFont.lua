local LoveFont = {}

function LoveFont.newFont(src, size)
	return love.graphics.newFont(src, size)
end

local function _getX_Y(x, y, text, font, box, modeW, modeH)
	if modeW == "center" then
		local w = font:getWidth(text)/2
		local dir = box.wP:copy()
		dir:normalize()
		dir = dir * w

		x,y = x + box.wP.x/2-dir.x, y + box.wP.y/2 -dir.y
	elseif modeW == "right" then
		local w = font:getWidth(text)
		local dir = box.wP:copy()
		dir:normalize()
		dir = dir * w

		x,y = x + box.wP.x - dir.x, y + box.wP.y - dir.y
	end

	local nbLines = 1
	for l in string.gmatch(text, "\n") do nbLines = nbLines + 1 end
	if modeH == "center" then
		local w = font:getHeight(text)*nbLines/2
		local dir = box.hP:copy()
		dir:normalize()
		dir = dir * w

		x,y = x + box.hP.x/2-dir.x, y + box.hP.y/2 -dir.y
	elseif modeH == "bottom" then
		local w = font:getHeight(text)*nbLines
		local dir = box.hP:copy()
		dir:normalize()
		dir = dir * w

		x,y = x + box.hP.x-dir.x, y + box.hP.y -dir.y
	end

	return x,y
end

function LoveFont.printAdapter(text, font, box, modeW, modeH, color)
	love.graphics.setColor(color.r, color.g, color.b, color.a)
	love.graphics.setFont(font)

	local x,y = _getX_Y(box.x, box.y, text, font, box, modeW, modeH)

	love.graphics.print(text, x, y, box.angle, 1, 1, 0, 0)
end

function LoveFont.printOutLineAdapter(text, font, box, modeW, modeH, color, colorOut, thickness)
	love.graphics.setColor(colorOut.r, colorOut.g, colorOut.b, colorOut.a)
	love.graphics.setFont(font)

	local x,y = _getX_Y(box.x, box.y, text, font, box, modeW, modeH)
	local wP, hP = box.wP:copy(), box.hP:copy()
	wP:normalize()
	hP:normalize()

	local b = {x = x, y = y}

	for i = -thickness,thickness do
		for j = -thickness,thickness do
			if i ~= j or i ~= 0 then
				b.x, b.y = x + i * (wP.x + hP.x), y + j * (wP.y + hP.y)
				love.graphics.print(text, b.x, b.y, box.angle, 1, 1, 0, 0)
			end
		end
	end

	love.graphics.setColor(color.r, color.g, color.b, color.a)
	love.graphics.print(text, x, y, box.angle, 1, 1, 0, 0)

	love.graphics.setColor(255,255,255,255)
end

function LoveFont.sizeOfAdapter(font, str)
	return font:getWidth(str), font:getHeight(str)
end

return LoveFont