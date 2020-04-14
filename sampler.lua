-- Copyright 2020, Sjors van Gelderen

require("area")
require("vector2")

local graphics = love.graphics
local image = love.image
local mouse = love.mouse

Sampler = {}

function Sampler.new()
   local self = {}
   
   self.samples = {
      { 1, 2, 3 },
      { 4, 5, 6 },
      { 7, 8, 9 },
      { 10, 11, 12 },
      { 13, 14, 15 },
      { 16, 17, 18 },
      { 19, 20, 21 },
      { 22, 23, 24 }
   }

   self.background_color = 64
   self.active_sample = 1
   self.active_color = 1
   
   local pixel_size = unit * 32
   
   self.size = Vec2.new(4, 15)
   self.pos = Vec2.new(screen.x - self.size.x * pixel_size, 0)

   function self.updateSamples()
      self.image_data:mapPixel(
	 function(x, y, r, g, b, a)
	    local v = 1
	    if y % 2 == 1 then
	       return 0, 0, 0, 0
	    end

	    local c = full_palette[self.background_color]

	    if x > 0 then
	       local s = self.samples[y / 2 + 1][x]
	       c = full_palette[s]
	    end
	    
	    return c[1] / 255, c[2] / 255, c[3] / 255, v
	 end
      )

      self.image:replacePixels(self.image_data)
   end

   self.image_data = image.newImageData(self.size.x, self.size.y)
   self.image = graphics.newImage(self.image_data)
   self.image:setFilter("nearest", "nearest")
   
   self.updateSamples()
   
   function self.assignColor(index)
      if self.active_color == 0 then
	 self.background_color = index
      else
	 self.samples[self.active_sample][self.active_color] = index
      end

      self.updateSamples()
      pattern.updateColors()
   end

   function self.mousepressed(x, y)
      local mp = Area.getPoint(self.pos, self.size.mul(pixel_size), getMousePosition())

      if mp ~= nil then
	 mp = mp.div(pixel_size).floor()

	 if mp.y % 2 == 0 then
	    local old_sample = self.active_sample
	    self.active_sample = math.floor(mp.y / 2) + 1

	    if old_sample ~= self.active_sample then
	       pattern.updateColors()
	    end

	    self.active_color = mp.x
	 end
	 
	 return true
      end
      
      return false
   end
   
   function self.draw()
      -- Lazy way of supporting window resizing
      pixel_size = unit * 32
      self.pos = Vec2.new(screen.x - self.size.x * pixel_size, 0)
      
      local mp = Area.getPoint(self.pos, self.size.mul(pixel_size), getMousePosition())
      
      graphics.setColor(146 / 255, 155 / 255, 150 / 255, 1)
      graphics.rectangle("fill", self.pos.x, 0, screen.x, screen.y)
      graphics.setColor(1, 1, 1, 1)
      graphics.draw(self.image, self.pos.x, self.pos.y, 0, pixel_size)

      graphics.setColor(0, 1, 1, 1)
      graphics.rectangle(
	 "line",
	 self.active_color * pixel_size + self.pos.x,
	 (self.active_sample - 1) * pixel_size * 2 + self.pos.y,
	 pixel_size, pixel_size
      )
      graphics.setColor(1, 0, 1, 1)

      if mp == nil then
	 return
      end
      
      local mpx = math.floor(mp.x / pixel_size)
      local mpy = math.floor(mp.y / pixel_size)
      
      if mpx >= 0 and mpx < 4 and
	 mpy >= 0 and mpy < 15 and
	 mpy % 2 == 0
      then
	 graphics.rectangle(
	    "line",
	    mpx * pixel_size + self.pos.x, mpy * pixel_size + self.pos.y,
	    pixel_size, pixel_size
	 )
      end
   end
   
   return self
end

sampler = nil
