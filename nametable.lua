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
   local mt_pixel_size = unit
   local mtw, mth = metatiler.image:getDimensions()
   
   self.zoom = 4
   -- TODO: fix this calculation, it doesn't center properly
   -- self.translation = Vec2.new(screen.x / 2 - 16 * 8 * mt_pixel_size * self.zoom, 0)
   self.translation = Vec2.new(screen.x / 2, 0)
   self.screen_metatile = Vec2.new(0, 0)
   self.metatiles = {}
   self.metatile = 1
   self.quads = {}
   self.dirty = false
   self.mouse_down = false
   
   -- 16 * 15 = 240 (16x16) metatiles, 960 (8x8) tiles
   for i = 1, 240 do
      table.insert(self.metatiles, 1)
      table.insert(self.quads, graphics.newQuad(0, 0, 16, 16, mtw, mth))
   end

   function self.refresh()
      for y = 1, 15 do
	 for x = 1, 16 do
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

   function self.mouseInput(x, y)
      local point = Area.getPoint(
         Vec2.new(0, 0),
         Vec2.new(mtw * mt_pixel_size, mth * mt_pixel_size),
         getMousePosition()
      )

      if not self.mouse_down and point ~= nil then
         self.dirty = true
         point = point.div(16 * mt_pixel_size).floor()
         self.metatile = point.y * 16 + point.x + 1
         
         return true
      else
         point = Area.getPoint(
            self.translation,
            Vec2.new(mtw * 16 * self.zoom, mth * 16 * self.zoom),
            getMousePosition()
         )
         
         if point ~= nil then
            self.mouse_down = true
            point = point.div(16 * self.zoom).floor()
            
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
   
   function self.mousemoved(mx, my, mdx, mdy)
      if translating then
         self.translation = self.translation.add(Vec2.new(mdx, mdy))
      elseif self.mouse_down then
         self.mouseInput(mx, my)
      end
   end

   function self.mousepressed(x, y)
      return self.mouseInput(x, y)
   end

   function self.mousereleased()
      self.mouse_down = false
   end
   
   function self.draw()
      graphics.setColor(1, 1, 1, 1)
      
      for y = 1, 15 do
	 for x = 1, 16 do
	    graphics.draw(
	       metatiler.image,
	       self.quads[(y - 1) * 16 + x],
	       self.translation.x + self.zoom * (x - 1) * 16,
	       self.translation.y + self.zoom * (y - 1) * 16,
	       0,
	       self.zoom,
	       self.zoom
	    )
	 end
      end

      graphics.setColor(1, 0, 1, 1)
      
      for i = 0, 16 do
	 graphics.line(
	    self.translation.x + i * 16 * self.zoom, self.translation.y,
	    self.translation.x + i * 16 * self.zoom, self.translation.y + 15 * 16 * self.zoom
	 )

         if i < 16 then
            graphics.line(
               self.translation.x, self.translation.y + i * 16 * self.zoom,
               self.translation.x + 16 * 16 * self.zoom, self.translation.y + i * 16 * self.zoom
            )
         end
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
