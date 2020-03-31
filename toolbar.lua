-- Copyright 2020, Sjors van Gelderen

require("area")
require("input")
require("vector2")

local graphics = love.graphics
local image = love.image
local mouse = love.mouse

Toolbar = {}

function Toolbar.new(pos, buttons)
   local self = {}
   self.pos = pos
   self.buttons = buttons
   
   for i = 1, #self.buttons do
      self.buttons[i].icon = graphics.newImage(buttons[i].icon)
      self.buttons[i].icon:setFilter("nearest", "nearest")
   end

   self.size = Vec2.new(
      math.floor(unit * 2) * 16 * #buttons,
      math.floor(unit * 2) * 16
   )

   function self.mousepressed(x, y)
      local mp = Area.getPoint(self.pos, self.size, getMousePosition())

      if mp ~= nil then
	 self.buttons[math.floor(mp.x / (math.floor(unit * 2) * 16)) + 1].action()
	 return true
      end

      return false
   end
   
   function self.draw()
      graphics.setColor(1, 1, 1, 1)
      
      for i, v in ipairs(self.buttons) do
	 graphics.draw(
	    v.icon,
	    (i - 1) * math.floor(unit * 2) * 16 + self.pos.x,
	    self.pos.y,
	    0,
	    math.floor(unit * 2)
	 )
      end
      
      graphics.setColor(1, 0, 1, 0)
   end
   
   return self
end
