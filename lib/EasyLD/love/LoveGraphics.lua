local LoveGraphics = {}

function LoveGraphics:rectangle(mode, box, color)
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(color.r, color.g, color.b, color.a)

	love.graphics.rectangle(mode, box.x, box.y, box.w, box.h)
	love.graphics.setColor(r, g, b, a)
end

function LoveGraphics:circle(mode, circle, nbSeg, color)
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(color.r, color.g, color.b, color.a)

	love.graphics.circle(mode, circle.x, circle.y, circle.r, nbSeg)
	love.graphics.setColor(r, g, b, a)
end

function LoveGraphics:polygon(mode, color, ...)
	local p = {}
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(color.r, color.g, color.b, color.a)

	for i,v in ipairs({...}) do
		table.insert(p, v.x)
		table.insert(p, v.y)
	end

	love.graphics.polygon(mode, unpack(p))
	love.graphics.setColor(r, g, b, a)
end

function LoveGraphics:point(p, color)
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(color.r, color.g, color.b, color.a)
	love.graphics.point(p.x, p.y)
	love.graphics.setColor(r, g, b, a)
end

function LoveGraphics:line(p1, p2, color)
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(color.r, color.g, color.b, color.a)
	love.graphics.line(p1.x, p1.y, p2.x, p2.y)
	love.graphics.setColor(r, g, b, a)
end

function LoveGraphics:triangle(mode, p1, p2, p3, color)
	LoveGraphics:polygon(mode, color, p1, p2, p3)
end

function LoveGraphics:setColor(color)
	color = color or EasyLD.color:new(255,255,255)
	love.graphics.setColor(color.r, color.g, color.b, color.a)
end


return LoveGraphics