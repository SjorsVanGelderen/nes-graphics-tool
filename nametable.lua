-- Copyright 2020, Sjors van Gelderen

require("area")
require("input")
require("vector2")

local graphics = love.graphics
local image = love.image
local mouse = love.mouse

Nametable = {}

function Nametable.new()
   local self = {}
   self.metatiles = {}
   self.metatile = 1
   self.quads = {}
   
   local mtw, mth = metatiler.image:getDimensions()
   local mt_pixel_size = unit
   
   -- 32 * 30 = 960 tiles
   for i = 1, 960 do
      table.insert(self.metatiles, 1)
      table.insert(self.quads, graphics.newQuad(0, 0, 16, 16, mtw, mth))
   end

   function self.refresh()
      for y = 1, 30 do
	 for x = 1, 32 do
	    local index = (y - 1) * 16 + x
      
	    self.quads[index]:setViewport(
	       (self.metatiles[index] - 1) % 16 * 16,
	       math.floor((self.metatiles[index] - 1) / 16) * 16,
	       16,
	       16,
	       mtw,
	       mth
            )
	 end
      end
   end

   function self.mousemoved(mx, my, mdx, mdy)
      
   end

   function self.mousepressed(x, y)
      local point = Area.getPoint(
	 Vec2.new(0, 0),
	 Vec2.new(mtw * mt_pixel_size, mth * mt_pixel_size),
	 getMousePosition()
      )

      if point ~= nil then
	 point = point.div(16 * mt_pixel_size).floor()
	 self.metatile = point.y * 16 + point.x + 1
	 
	 return true
      else
	 point = Area.getPoint(
	    translation,
	    Vec2.new(mtw * 16 * zoom, mth * 16 * zoom),
	    getMousePosition()
	 )
	 
	 if point ~= nil then
	    point = point.div(16 * zoom).floor()
	    
	    local index = point.y * 16 + point.x + 1
	    self.metatiles[index] = self.metatile
	    
	    self.quads[index]:setViewport(
	       (self.metatile - 1) % 16 * 16,
	       math.floor((self.metatile - 1) / 16) * 16,
	       16,
	       16,
	       mtw,
	       mth
	    )
	       
	    return true
	 end
      end
      
      return false
   end
   
   function self.draw()
      graphics.setColor(1, 1, 1, 1)
      
      for y = 1, 15 do
	 for x = 1, 16 do
	    graphics.draw(
	       metatiler.image,
	       self.quads[(y - 1) * 16 + x],
	       translation.x + zoom * (x - 1) * 16,
	       translation.y + zoom * (y - 1) * 16,
	       0,
	       zoom,
	       zoom
	    )
	 end
      end

      graphics.setColor(1, 0, 1, 1)
      
      for i = 0, 16 do
	 graphics.line(
	    translation.x + i * 16 * zoom, translation.y,
	    translation.x + i * 16 * zoom, translation.y + 16 * 16 * zoom
	 )
	 
	 graphics.line(
	    translation.x, translation.y + i * 16 * zoom,
	    translation.x + 16 * 16 * zoom, translation.y + i * 16 * zoom
	 )
      end

      graphics.setColor(1, 1, 1, 1)
      graphics.draw(metatiler.image, 0, 0, 0, mt_pixel_size, mt_pixel_size)

      graphics.setColor(1, 1, 0, 1)
      graphics.rectangle(
	 "line",
	 (self.metatile - 1) % 16 * mt_pixel_size * 16,
	 math.floor((self.metatile - 1) / 16) * mt_pixel_size * 16,
	 mt_pixel_size * 16,
	 mt_pixel_size * 16
      )
      
      graphics.setColor(1, 0, 1, 1)
      
      local point = Area.getPoint(
	 Vec2.new(0, 0),
	 Vec2.new(mtw * mt_pixel_size, mth * mt_pixel_size),
	 getMousePosition()
      )

      if point ~= nil then
	 point = point.div(mt_pixel_size * 16).floor()
	 
      	 graphics.rectangle(
      	    "line",
      	    point.x * mt_pixel_size * 16, point.y * mt_pixel_size * 16,
      	    mt_pixel_size * 16, mt_pixel_size * 16
      	 )
      end
      
      graphics.setColor(1, 0, 1, 0)
   end
   
   return self
end

nametable = nil
