-- Copyright 2020, Sjors van Gelderen

require("area")
require("input")
require("vector2")

local graphics = love.graphics
local image = love.image
local mouse = love.mouse

Metatiler = {}

-- TODO:
-- Allow creation of metasprites
-- Investigate whether background tiles support mirroring or not

function Metatiler.new()
   local self = {}
   local pq_pixel_size = unit * 2
   local pq_tile_size = pq_pixel_size * 8
   local pqw, pqh = pattern.tone_image_data:getDimensions()
   local mt_pixel_size = math.floor(unit)
   local mt_tile_size = mt_pixel_size * 16

   self.image_data = image.newImageData(256, 256)
   self.image = graphics.newImage(self.image_data)
   self.image:setFilter("nearest", "nearest")
   
   self.patternQuad = graphics.newQuad(0, pqh / 2, pqw, pqh / 2, pqw, pqh)
   self.tile = 1
   self.tiles = {}
   self.samples = {} -- Palettes for attribute table
   
   for i = 1, 1024 do
      table.insert(self.tiles, 1)
      table.insert(self.samples, 1)
   end

   local function updateTileInImage(x, y)
      local index = (y - 1) * 32 + x
      local tile = self.tiles[index]
      local ox = (tile - 1) % 16 * 8
      local oy = math.floor((tile - 1) / 16) * 8
      
      for ty = 1, 8 do
	 for tx = 1, 8 do
	    local r, g, b, a = pattern.tone_image_data:getPixel(
	       ox + (tx - 1), oy + (ty - 1) + 128
	    )

	    local tone = math.floor(r * 3)
	    local c = { 1, 0, 1, 1 }
	    
	    if tone == 0 then
	       c = full_palette[sampler.background_color]
	    else
	       c = full_palette[sampler.samples[self.samples[index]][tone]]
	    end

	    r, g, b = c[1] / 255, c[2] / 255, c[3] / 255
	    
	    self.image_data:setPixel(
	       (x - 1) * 8 + (tx - 1), (y - 1) * 8 + (ty - 1), r, g, b, 1
	    )
	 end
      end

      self.image:replacePixels(self.image_data)
   end

   function self.generateImage()
      for y = 1, 32 do
      	 for x = 1, 32 do
	    updateTileInImage(x, y)
      	 end
      end

      self.image:replacePixels(self.image_data)
   end

   function self.mousemoved(mx, my, mdx, mdy)
      
   end

   function self.mousepressed(x, y)
      local point = Area.getPoint(
	 Vec2.new(0, 0),
	 Vec2.new(pqw * pq_pixel_size, (pqh / 2) * pq_pixel_size),
	 getMousePosition()
      )

      if point ~= nil then
	 point = point.div(pq_tile_size).floor()
	 self.tile = point.y * 16 + point.x + 1
	 
	 return true
      else
	 point = Area.getPoint(
	    translation,
	    Vec2.new(mt_tile_size * 16 * zoom, mt_tile_size * 16 * zoom),
	    getMousePosition()
	 )
	 
	 if point ~= nil then
	    point = point.div((mt_tile_size / 2) * zoom).floor()
	    local tileIndex = point.y * 32 + point.x + 1
	    self.tiles[tileIndex] = self.tile
	    self.samples[tileIndex] = sampler.active_sample
	    updateTileInImage(point.x + 1, point.y + 1)
	    
	    return true
	 end
      end
      
      return false
   end
   
   function self.draw()
      graphics.setColor(1, 1, 1, 1)
      graphics.draw(
	 self.image,
	 translation.x,
	 translation.y,
	 0,
	 mt_pixel_size * zoom,
	 mt_pixel_size * zoom
      )
      
      graphics.setColor(1, 0, 1, 1)
      
      for i = 0, 16 do
	 graphics.line(
	    translation.x + i * mt_tile_size * zoom, translation.y,
	    translation.x + i * mt_tile_size * zoom, translation.y + mt_tile_size * 16 * zoom
	 )
	 
	 graphics.line(
	    translation.x, translation.y + i * mt_tile_size * zoom,
	    translation.x + mt_tile_size * 16 * zoom, translation.y + i * mt_tile_size * zoom
	 )
      end
      
      graphics.setColor(1, 1, 1, 1)
      graphics.draw(pattern.image, self.patternQuad, 0, 0, 0, pq_pixel_size, pq_pixel_size)
      
      graphics.setColor(1, 1, 0, 1)
      graphics.rectangle(
	 "line",
	 (self.tile - 1) % 16 * pq_tile_size, math.floor((self.tile - 1) / 16) * pq_tile_size,
	 pq_tile_size, pq_tile_size
      )
      
      graphics.setColor(1, 0, 1, 1)
      
      local point = Area.getPoint(
	 Vec2.new(0, 0),
	 Vec2.new(pqw * pq_pixel_size, (pqh / 2) * pq_pixel_size),
	 getMousePosition()
      )

      if point ~= nil then
	 point = point.div(pq_tile_size).floor()
	 
      	 graphics.rectangle(
      	    "line",
      	    point.x * pq_tile_size, point.y * pq_tile_size,
      	    pq_tile_size, pq_tile_size
      	 )
      end

      graphics.setColor(1, 0, 1, 0)
   end
   
   return self
end

metatiler = nil
