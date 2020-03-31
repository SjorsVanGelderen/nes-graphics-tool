-- Copyright 2020, Sjors van Gelderen

require("fullpalette")
require("input")
require("sampler")
require("vector2")

local graphics = love.graphics
local image = love.image

Palette = {}

function Palette.new()
   local self = {}
   self.pos = Vec2.new(0, 0)
   self.size = Vec2.new(4, 16)

   self.image_data = image.newImageData(self.size.x, self.size.y)
   self.image_data:mapPixel(
      function(x, y, r, g, b, a)
	 local c = full_palette[x * 16 + y + 1]
	 return c[1] / 255, c[2] / 255, c[3] / 255, 1
      end
   )

   self.image = graphics.newImage(self.image_data)
   self.image:setFilter("nearest", "nearest")
   
   local pixel_size = unit * 32

   function self.mousepressed(x, y)
      local mp = Area.getPoint(self.pos, self.size.mul(pixel_size), getMousePosition())

      if mp ~= nil then
	 mp = mp.div(pixel_size).floor()
	 local index = mp.x * 16 + mp.y + 1
	 sampler.assignColor(index)
	 return true
      end
      
      return false
   end
   
   function self.draw()      
      graphics.setColor(146 / 255, 155 / 255, 150 / 255, 1)
      graphics.rectangle("fill", 0, 0, self.size.x * pixel_size, screen.y)
      graphics.setColor(1, 1, 1, 1)
      graphics.draw(self.image, 0, 0, 0, pixel_size)
      graphics.setColor(1, 0, 1, 1)

      local mp = getMousePosition()
      local point = Area.getPoint(self.pos, self.size.mul(pixel_size), mp)
      
      if point ~= nil then
	 point = point.div(pixel_size).floor()
	 graphics.rectangle(
	    "line",
	    point.x * pixel_size, point.y * pixel_size,
	    pixel_size, pixel_size
	 )
      end
   end
   
   return self
end

palette = nil
