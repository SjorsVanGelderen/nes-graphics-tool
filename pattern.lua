-- Copyright 2020, Sjors van Gelderen

require("area")
require("disk")
require("input")
require("vector2")

local graphics = love.graphics
local image = love.image
local mouse = love.mouse

Pattern = {}

function Pattern.new()
   local self = {}
   self.size = Vec2.new(128, 256)
   self.drawing_points = {}
   self.plot_start = nil
   self.tone_image_data = image.newImageData(self.size.x, self.size.y)
   self.image_data = image.newImageData(self.size.x, self.size.y)
   self.image = graphics.newImage(self.image_data)
   self.image:setFilter("nearest", "nearest")

   function self.replacePixels(pixels)
      self.tone_image_data:mapPixel(
	 function(x, y, r, g, b, a)
	    return pixels[y * self.size.x + x + 1], 0, 0, 0
	 end
      )
   end

   function self.updateColors()
      self.image_data:mapPixel(
	 function(x, y, r, g, b, a)
	    local r, g, b, a = self.tone_image_data:getPixel(x, y)
	    local tone = math.floor(r * 3)
	    local c = { 1, 0, 1, 1 }
	    
	    if tone == 0 then
	       c = full_palette[sampler.background_color]
	    else
	       c = full_palette[sampler.samples[sampler.active_sample][tone]]
	    end
	    
	    return c[1] / 255, c[2] / 255, c[3] / 255, 1
	 end
      )

      self.image:replacePixels(self.image_data)
   end
   
   self.updateColors()

   self.drawing_image_data = image.newImageData(self.size.x, self.size.y)
   self.drawing_image_data:mapPixel(
      function(x, y, r, g, b, a)
	 return 0, 0, 0, 0
      end
   )

   self.drawing_image = graphics.newImage(self.drawing_image_data)
   self.drawing_image:setFilter("nearest", "nearest")
   
   local function processDrawing(mode)
      if mode == "clear" then
	 for i = 1, #self.drawing_points do
	    local p = self.drawing_points[i]
	    self.drawing_image_data:setPixel(p.x, p.y, 0, 0, 0, 0)
	 end

	 self.drawing_points = {}
      else
	 local c = nil
	 
	 if sampler.active_color % 4 == 0 then
	    c = full_palette[sampler.background_color]
	 else
	    c = full_palette[sampler.samples[sampler.active_sample][sampler.active_color]]
	 end

	 c = { c[1] / 255, c[2] / 255, c[3] / 255 }
	 	 
	 for i = 1, #self.drawing_points do
	    local p = self.drawing_points[i]
	    self.drawing_image_data:setPixel(p.x, p.y, c[1], c[2], c[3], 1)

	    if mode == "apply" then
	       self.tone_image_data:setPixel(p.x, p.y, sampler.active_color / 3, 0, 0, 0)
	       self.image_data:setPixel(p.x, p.y, c[1], c[2], c[3], 1)
	    end
	 end
	 
	 self.image:replacePixels(self.image_data)
      end
      
      self.drawing_image:replacePixels(self.drawing_image_data)
   end

   function self.mousemoved(mx, my, mdx, mdy)      
      local point = Area.getPoint(translation, self.size.mul(zoom), Vec2.new(mx, my))

      processDrawing("clear")
      
      if point ~= nil then
	 point = point.div(zoom).floor()

	 self.drawing_points = { point }

	 if tool == 1 then -- Pencil
	    -- self.drawing_points = { point }
	    
	    local c = nil
	    
	    if sampler.active_color % 4 == 0 then
	       c = full_palette[sampler.background_color]
	    else
	       c = full_palette[sampler.samples[sampler.active_sample][sampler.active_color]]
	    end

	    c = { c[1] / 255, c[2] / 255, c[3] / 255 }

	    if mouse.isDown(1) then
	       self.tone_image_data:setPixel(point.x, point.y, sampler.active_color / 3, 0, 0, 0)
	       self.image_data:setPixel(point.x, point.y, c[1], c[2], c[3], 1)
	       self.image:replacePixels(self.image_data)
	    end
	 else
	    if self.plot_start == nil then
	       processDrawing("preview")
	       return
	    end
	    
	    if tool == 2 then -- Line
	       self.drawing_points = bresenhamLine(self.plot_start, point)
	    elseif tool == 3 then -- Rectangle	    
	       local left = self.plot_start.x
	       local right = point.x
	       if point.x < self.plot_start.x then
		  left = point.x
		  right = self.plot_start.x
	       end

	       local top = self.plot_start.y
	       local bottom = point.y
	       if point.y < self.plot_start.y then
		  top = point.y
		  bottom = self.plot_start.y
	       end

	       if fill then
		  for y = top, bottom do
		     for x = left, right do
			table.insert(self.drawing_points, Vec2.new(x, y))
		     end
		  end
	       else
		  for x = left, right do
		     table.insert(self.drawing_points, Vec2.new(x, top))
		     table.insert(self.drawing_points, Vec2.new(x, bottom))
		  end

		  for y = top, bottom do
		     table.insert(self.drawing_points, Vec2.new(left, y))
		     table.insert(self.drawing_points, Vec2.new(right, y))
		  end
	       end
	    elseif tool == 4 then -- Ellipse
	       self.drawing_points = bresenhamEllipse(self.plot_start, point)
	    end
	 end

	 processDrawing("preview")
      end
   end
   
   function self.mousepressed(x, y, button)
      if button == 1 and self.plot_start == nil then
	 self.plot_start = Area.getPoint(translation, self.size.mul(zoom), Vec2.new(x, y))
	 
	 if self.plot_start ~= nil then
	    self.plot_start = self.plot_start.div(zoom).floor()

	    if tool == 1 and mouse.isDown(1) then -- Pencil
	       local c = nil
	       
	       if sampler.active_color % 4 == 0 then
		  c = full_palette[sampler.background_color]
	       else
		  c = full_palette[sampler.samples[sampler.active_sample][sampler.active_color]]
	       end

	       c = { c[1] / 255, c[2] / 255, c[3] / 255 }

	       self.tone_image_data:setPixel(
		  self.plot_start.x, self.plot_start.y,
		  sampler.active_color / 3, 0, 0, 0
	       )
	       
	       self.image_data:setPixel(self.plot_start.x, self.plot_start.y, c[1], c[2], c[3], 1)
	       self.image:replacePixels(self.image_data)
	    end
	    
	    return true
	 end
      end
      
      return false
   end

   function self.mousereleased(x, y)
      if self.plot_start ~= nil then
	 self.plot_start = nil
	 processDrawing("apply")
      end
   end
   
   function self.draw()
      graphics.setColor(1, 1, 1, 1)
      graphics.draw(self.image, translation.x, translation.y, 0, zoom)
      graphics.draw(self.drawing_image, translation.x, translation.y, 0, zoom)
      graphics.setColor(1, 0, 1, 1)

      for i = 0, self.size.y / 8 do
	 if i < 17 then
	    graphics.line(
	       i * 8 * zoom + translation.x, translation.y,
	       i * 8 * zoom + translation.x, self.size.y * zoom + translation.y
	    )
	 end

	 if i == self.size.y / 16 then
	    graphics.setColor(0, 1, 1, 1)
	 end
	 
	 graphics.line(
	    translation.x, i * 8 * zoom + translation.y,
	    self.size.x * zoom + translation.x, i * 8 * zoom + translation.y
	 )

	 graphics.setColor(1, 0, 1, 1)
      end
   end
   
   return self
end

pattern = nil
