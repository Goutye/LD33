local class = require 'EasyLD.lib.middleclass'

local Tileset = class('Tileset')

function Tileset:initialize(src, tileSize, tileSizeY)
	self.img = EasyLD.image:new(src)

	self.tileSize = tileSize
	self.tileSizeY = tileSizeY or tileSize

	self.nbTilesW = math.floor(self.img.w/self.tileSize)
	self.nbTilesH = math.floor(self.img.h/self.tileSizeY)

	self.w = self.nbTilesW * self.tileSize
	self.h = self.nbTilesH * self.tileSizeY
end

function Tileset:drawTile(id, mapX, mapY)
	local x,y = id % self.nbTilesW, math.floor(id / self.nbTilesW)

	if id < self.nbTilesH * self.nbTilesW then
		self.img:drawPart(mapX, mapY, x * self.tileSize, y * self.tileSizeY, self.tileSize, self.tileSizeY, id)
	end
end

function Tileset:draw(x, y, nbTilesX, nbTilesY, beginX, beginY)
	for i = 0, nbTilesX-1 do
		for j = 0, nbTilesY-1 do
			if i + beginX < self.nbTilesW and j + beginY < self.nbTilesH then
				self:drawTile(i + beginX + (j + beginY) * self.nbTilesW, x + i * self.tileSize, y + j * self.tileSizeY)
			end
		end
	end
end

return Tileset