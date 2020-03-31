-- Copyright 2020, Sjors van Gelderen

local graphics = love.graphics
local image = love.image

Tile = {}

function Tile.new()
   local self = {}
   self.image_data = image.newImageData(8, 8)
   
   self.image_data:mapPixel(
      function(x, y, r, g, b, a)
	 local v = 
	 return 1, 1, 1, 1 --v, v, v, 1
      end
   )
   
   self.image = graphics.newImage(self.image_data)
   self.image:setFilter("nearest", "nearest")

   function self.update()
      self.image_data:mapPixel(
	 function(x, y, r, g, b, a)
	    return math.random(), math.random(), math.random(), 1
	 end
      )
      self.image:replacePixels(self.image_data)
   end
   
   function self.draw(x, y, zoom)
      graphics.setColor(1, 1, 1, 1)
      graphics.draw(self.image, x * zoom, y * zoom, 0, zoom, zoom)
      graphics.setColor(1, 0, 1, 1)
   end

   return self
end
