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

function Metatiler.new()
   local self = {}
   local pq_pixel_size = unit * 2
   local pq_tile_size = pq_pixel_size * 8
   local pqw, pqh = pattern.tone_image_data:getDimensions()
   local mt_pixel_size = math.floor(unit)
   local mt_tile_size = mt_pixel_size * 16

   self.zoom = 8
   self.translation = Vec2.new(0, 0)
   self.image_data = image.newImageData(256, 256)
   self.image = graphics.newImage(self.image_data)
   self.image:setFilter("nearest", "nearest")
   self.patternQuad = graphics.newQuad(0, pqh / 2, pqw, pqh / 2, pqw, pqh)
   self.metatile = 0
   self.tile = 1
   self.tiles = {}
   self.samples = {}
   
   for i = 1, 1024 do
      table.insert(self.tiles, 1)
      
      if i <= 256 then
         table.insert(self.samples, 1)
      end
   end

   local function updateTileInImage(x, y)
      local tileIndex = (y - 1) * 32 + x
      local sampleIndex = math.floor((y - 1) / 2) * 16 + math.floor((x - 1) / 2) + 1
      local tile = self.tiles[tileIndex]
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
               c = full_palette[sampler.samples[self.samples[sampleIndex]][tone]]
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
      if translating then
         self.translation = self.translation.add(Vec2.new(mdx, mdy))
      end
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
	    self.translation,
	    Vec2.new(mt_tile_size * 16 * self.zoom, mt_tile_size * 16 * self.zoom),
	    getMousePosition()
	 )
	 
	 if point ~= nil then
	    local tilePoint = point.div((mt_tile_size / 2) * self.zoom).floor()
	    local tileIndex = tilePoint.y * 32 + tilePoint.x + 1
	    self.tiles[tileIndex] = self.tile

            local p = point.div(mt_tile_size * self.zoom).floor()
            point = p.mul(2).add(Vec2.new(1, 1))

            local s = p.y * 16 + p.x + 1
	    self.samples[s] = sampler.active_sample

            -- This is pretty lazy, the function needs to only be called once
            -- and should apply to the metatile instead of a single tile
            -- It's like this because I thought the attributes worked differently at first
	    updateTileInImage(point.x, point.y)
	    updateTileInImage(point.x + 1, point.y)
	    updateTileInImage(point.x, point.y + 1)
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
	 self.translation.x,
	 self.translation.y,
	 0,
	 mt_pixel_size * self.zoom,
	 mt_pixel_size * self.zoom
      )
      
      graphics.setColor(1, 0, 1, 1)
      
      for i = 0, 16 do
	 graphics.line(
	    self.translation.x + i * mt_tile_size * self.zoom, self.translation.y,
	    self.translation.x + i * mt_tile_size * self.zoom, self.translation.y + mt_tile_size * 16 * self.zoom
	 )
	 
	 graphics.line(
	    self.translation.x, self.translation.y + i * mt_tile_size * self.zoom,
	    self.translation.x + mt_tile_size * 16 * self.zoom, self.translation.y + i * mt_tile_size * self.zoom
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
