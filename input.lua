-- Copyright 2020, Sjors van Gelderen

local mouse = love.mouse

function getMousePosition()
   local mx, my = mouse.getPosition()
   return Vec2.new(mx, my)
end
