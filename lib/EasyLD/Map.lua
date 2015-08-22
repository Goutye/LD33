local class = require 'EasyLD.lib.middleclass'

local Map = class('Map')

function Map.static:generate(w, h, tileset)
	local m = Map:new("", tileset, true)
	m.w = w
	m.h = h
	m.tiles = {}
	m.infos = {}
	
	for x = 0, m.w - 1 do
		m.tiles[x] = {}
		m.infos[x] = {}
		for y = 0, m.h - 1 do
			m:putTile(0, x, y)
			m.infos[x][y] = 0 
		end
	end
	return m
end

function Map:initialize(src, tileset, noLoad)
	self.src = src
	self.tileset = tileset
	self.tileCollideBoxes = {}
	self.collideBoxes = {}
	self.tileHoleBoxes = {}
	self.holeBoxes = {}
	self.offset = EasyLD.point:new(0,0)
	if not noLoad then
		self:load()
	end
end

function Map:load()
	io.input(self.src)
	self.tiles = {}
	self.w, self.h = io.read("*number", "*number")
	self.tiles = {}
	self.infos = {}

	for i = 0, self.w -1 do
		self.tiles[i] = {}
		self.infos[i] = {}
		for j = 0, self.h - 1 do
			self.tiles[i][j] = io.read("*number")
			self.infos[i][j] = io.read("*number")
		end
	end

	if self.tiles[self.w-1][self.h-1] == nil then
		print("bad format")
	end

	local nbBoxes = io.read("*number") or 0
	for i = 1, nbBoxes do
		table.insert(self.tileCollideBoxes, EasyLD.box:new(io.read("*number", "*number", "*number", "*number")))
	end
	self:loadCollideBoxes(self.tileCollideBoxes)

	local nbBoxes = io.read("*number") or 0
	for i = 1, nbBoxes do
		table.insert(self.tileHoleBoxes, EasyLD.box:new(io.read("*number", "*number", "*number", "*number")))
	end
	self:loadHoleBoxes(self.tileHoleBoxes)

	io.input():close()
end

function Map:save()
	io.output(self.src)
	io.write(self.w .. " " .. self.h .. "\n")

	for x = 0, self.w - 1 do
		for y = 0, self.h - 1 do
			io.write(self:getTile(x, y) .. " " .. self.infos[x][y] .. " ")
		end
	end

	--collideBoxes

	io.write("\n" .. #self.tileCollideBoxes .. "\n")
	for _,box in ipairs(self.tileCollideBoxes) do
		io.write(box.x .. " " .. box.y .. " " .. box.w .. " " .. box.h .. "\n")
	end

	io.write("\n" .. #self.tileHoleBoxes .. "\n")
	for _,box in ipairs(self.tileHoleBoxes) do
		io.write(box.x .. " " .. box.y .. " " .. box.w .. " " .. box.h .. "\n")
	end

	io.output():close()
end

function Map:resize(x, y)
	self.w = self.w + x
	self.h = self.h + y

	if x > 0 then
		self.tiles[self.w-1] = {}
		for i = 0, self.h-1 do
			self.tiles[self.w-1][i] = 0
		end
	end
	if y > 0 then
		for i = 0, self.w-1 do
			self.tiles[i][self.h-1] = 0
		end
	end
end

function Map:getTile(x, y)
	return self.tiles[x][y]
end

function Map:getTilePixel(x, y)
	local realX, realY = math.floor((x - self.offset.x)/self.tileset.tileSize), math.floor((y - self.offset.y)/self.tileset.tileSizeY)
	return self.tiles[realX][realY], realX, realY
end

function Map:getInfos(x, y)
	return self.infos[x][y]
end

function Map:putTile(id, x, y)
	self.tiles[x][y] = id
end

function Map:loadCollideBoxes(boxes)
	local W,H = self.tileset.tileSize, self.tileset.tileSizeY
	for _,box in ipairs(boxes) do
		table.insert(self.collideBoxes, EasyLD.box:new(box.x * W, box.y * H, box.w * W, box.h * H))
	end
end

function Map:loadHoleBoxes(boxes)
	local W,H = self.tileset.tileSize, self.tileset.tileSizeY
	for _,box in ipairs(boxes) do
		table.insert(self.holeBoxes, EasyLD.box:new(box.x * W, box.y * H, box.w * W, box.h * H))
	end
end

function Map:collide(entityArea)
	for _,box in ipairs(self.collideBoxes) do
		if box:collide(entityArea) then
			return true
		end
	end

	return false
end

function Map:collideHole(entityArea)
	for _,box in ipairs(self.holeBoxes) do
		if box:collide(entityArea, true) then
			return true
		end
	end

	return false 
end

function Map:draw(x, y, nbTilesX, nbTilesY, beginX, beginY)
	if x ~= self.offset.x or y ~= self.offset.y then
		for _,box in ipairs(self.collideBoxes) do
			box:translate(x - self.offset.x, y - self.offset.y)
		end
		self.offset.x = x
		self.offset.y = y
	end
	for j = 0, nbTilesY-1 do	
		for i = 0, nbTilesX-1 do
			if i + beginX < self.w and j + beginY < self.h then
				self.tileset:drawTile(self.tiles[i + beginX][j + beginY], x + i * self.tileset.tileSize, y + j * self.tileset.tileSizeY)
			end
		end
	end
end

return Map