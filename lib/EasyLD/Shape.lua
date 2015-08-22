local class = require 'EasyLD.lib.middleclass'
local Shape = class('Shape')

function Shape:initialize()
end

function Shape:attachImg(img, imgType)
	self.img = img
	self.imgType = imgType
	self.imgW = {x = img.w/2, y = 0}
	self.imgH = {x = 0, y = img.h/2}
end

return Shape