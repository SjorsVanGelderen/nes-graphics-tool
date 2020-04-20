-- Copyright 2020, Sjors van Gelderen

require("vector2")
require("bresenham")
require("constrain")
require("disk")
require("toolbar")
require("metatiler")
require("nametable")
require("palette")
require("pattern")
require("sampler")

local graphics = love.graphics
local window = love.window
local font = nil
local mode = "pattern"

screen = nil
unit = nil
metatiler = nil
nametable = nil
palette = nil
pattern = nil
sampler = nil
translating = false
hint = ""

-- Tools
-- 1 pencil
-- 2 line
-- 3 rectangle
-- 4 ellipse
tool = 1
fill = false

local left_toolbar = nil
local right_toolbar = nil

function love.load()
   window.setTitle("NES Graphics Tool")
   window.setMode(
      1600, 900,
      { resizable = true,
	minwidth = 800,
	minheight = 600
   })
   
   font = love.graphics.newFont("unifont.ttf", 32, "none")
   graphics.setFont(font)
   
   screen = Vec2.new(graphics.getWidth(), graphics.getHeight())
   unit = screen.y / 600

   palette = Palette.new()
   sampler = Sampler.new()
   pattern = Pattern.new()
   metatiler = Metatiler.new()
   nametable = Nametable.new()
   
   left_toolbar = Toolbar.new(
      Vec2.new(0, screen.y - math.floor(unit * 2) * 16), {
	 { icon = "pencilbutton.png",
	   action = function() tool = 1 end },
	 { icon = "linebutton.png",
	   action = function() tool = 2 end },
	 { icon = "rectanglebutton.png",
	   action = function() tool = 3 end },
	 { icon = "ellipsebutton.png",
	   action = function() tool = 4 end },
	 { icon = "rectanglebuttonfill.png",
	   action = function() fill = not fill end }
   })

   right_toolbar = Toolbar.new(
      Vec2.new(screen.x - math.floor(unit * 2) * 16 * 2, screen.y - math.floor(unit * 2) * 16), {
	 { icon = "savebutton.png",
	   action = function() saveProject() end },
	 { icon = "loadbutton.png",
	   action = function() loadProject() end }
   })
end

function love.keypressed(key, scancode, isrepeat)
   if key == "escape" then
      if pattern.dirty or metatiler.dirty or nametable.dirty then
         print("There are unsaved changes. Are you sure you want to quit? y/n")
         response = io.read()

         if response == nil or response == "n" or response == "no" or
            (response ~= "y" and response ~= "yes")
         then
            print("Canceled!")
            return
         end
      end
      
      love.event.quit()
      return
   elseif key == "space" and not translating then
      love.mouse.setCursor(love.mouse.getSystemCursor("sizeall"))
      translating = true
   elseif key == "g" then
      metatiler.generateImage()
   elseif key == "1" then
      mode = "pattern"
   elseif key == "2" then
      mode = "metatiler"
   elseif key == "3" then
      mode = "nametable"
   end
end

function love.keyreleased(key, scancode)
   if key == "space" and translating then
      love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
      translating = false
   end
end

function love.mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      if right_toolbar.mousepressed(x, y) then
	 return
      elseif sampler.mousepressed(x, y) then
	 return
      end
      
      if mode == "pattern" then
	 if left_toolbar.mousepressed(x, y) then
	    return
	 elseif palette.mousepressed(x, y) then
	    return
	 elseif pattern.mousepressed(x, y, button) then
	    return
	 end
      elseif mode == "metatiler" then
	 if metatiler.mousepressed(x, y) then
	    return
	 end
      elseif mode == "nametable" then
	 if nametable.mousepressed(x, y) then
	    return
	 end
      end
   elseif button == 2 and not translating then
      love.mouse.setCursor(love.mouse.getSystemCursor("sizeall"))
      translating = true
   end
end

function love.mousereleased(x, y, button, istouch, presses)
   nametable.mousereleased()
   
   if button == 1 and mode == "pattern" then
      pattern.mousereleased(x, y)
   elseif button == 2 and translating then
      love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
      translating = false
   end
end

function love.mousemoved(x, y, dx, dy, istouch)   
   if mode == "pattern" then
      pattern.mousemoved(x, y, dx, dy)
   elseif mode == "metatiler" then
      metatiler.mousemoved(x, y, dx, dy)
   elseif mode == "nametable" then
      nametable.mousemoved(x, y, dx, dy)
   end
end

function love.wheelmoved(x, y)
   if mode == "pattern" then
      pattern.zoom = constrain(pattern.zoom + y * 0.1, 4, 32)
   elseif mode == "metatiler" then
      metatiler.zoom = constrain(metatiler.zoom + y * 0.1, 4, 32)
   elseif mode == "nametable" then
      nametable.zoom = constrain(nametable.zoom + y * 0.1, 4, 32)
   end
end

function love.resize(w, h)
   unit = screen.y / 600
   screen = Vec2.new(w, h)

   -- Lazy way of supporting window resizing
   right_toolbar.pos = Vec2.new(screen.x - math.floor(unit * 2) * 16 * 2, screen.y - math.floor(unit * 2) * 16)
end

function love.update()
   if mode == "pattern" then
      hint = "pattern | tile " .. pattern.tile .. " | px " .. pattern.px.x .. "," .. pattern.px.y
   elseif mode == "metatiler" then
      hint = "metatiler | metatile " .. metatiler.metatile
   elseif mode == "nametable" then
      hint = "nametable | screen metatile " .. nametable.screen_metatile.x .. "," .. nametable.screen_metatile.y
   end

   -- This does not need to happen every frame, but it will serve for now
   local star = ""
   if pattern.dirty or metatiler.dirty or nametable.dirty then
      star = " *"
   end
   
   window.setTitle("NES Graphics Tool" .. star)
end

function love.draw()
   if mode == "pattern" then
      pattern.draw()
      palette.draw()
      left_toolbar.draw()
   elseif mode == "metatiler" then
      metatiler.draw()
   elseif mode == "nametable" then
      nametable.draw()
   end

   sampler.draw()
   right_toolbar.draw()

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.print(hint, screen.x / 2 - font:getWidth(hint) / 2, screen.y - font:getHeight())
   love.graphics.setColor(1, 0, 1, 0)
end
