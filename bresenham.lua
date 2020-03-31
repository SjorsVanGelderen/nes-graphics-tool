-- Copyright 2020, Sjors van Gelderen

require("vector2")

-- Ported from Bresenham's line algorithm
-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
function bresenhamLine(one, two)
   local x1 = one.x
   local y1 = one.y
   local x2 = two.x
   local y2 = two.y
   local dx = x2 - x1
   local dy = y2 - y1
   local derr = 0
   local err = 0
   local x = x1
   local y = y1
   local points = {}

   local xs = 1
   if dx < 0 then
      xs = -1
   end
   
   local ys = 1
   if dy < 0 then
      ys = -1
   end

   local algorithmX = function(x)
      table.insert(points, Vec2.new(x, y))
      err = err + derr
      
      if err >= 0.5 then
	 y = y + ys
	 err = err - 1
      end
   end
   
   local algorithmY = function(y)
      table.insert(points, Vec2.new(x, y))
      err = err + derr
      
      if err >= 0.5 then
	 x = x + xs
	 err = err - 1
      end
   end

   if math.abs(dx) > math.abs(dy) then
      derr = math.abs(dy / dx)
      
      if dx > 0 then
	 for x = x1, x2 - 1 do
	    algorithmX(x)
	 end
      else
	 for x = x1 - 1, x2, -1 do
	    algorithmX(x)
	 end
      end
   else
      derr = math.abs(dx / dy)

      if dy > 0 then
	 for y = y1, y2 - 1 do
	    algorithmY(y)
	 end
      else
	 for y = y1 - 1, y2, -1 do
	    algorithmY(y)
	 end
      end
   end

   return points
end

-- Ported from Alois Zingl's ellipse algorithm
-- http://members.chello.at/easyfilter/bresenham.html#ellipse
function bresenhamEllipse(one, two)
   local x1 = one.x
   local y1 = one.y
   local x2 = two.x
   local y2 = two.y
   local a = math.abs(x2 - x1)
   local b = math.abs(y2 - y1)
   local b1 = bit.band(b, 1)
   local dx = 4 * (1 - a) * b * b
   local dy = 4 * (b1 + 1) * a * a
   local err = dx + dy + b1 * a * a
   local e2 = nil
   local points = {}

   if x1 > x2 then
      x1 = x2
      x2 = x2 + a
   end

   if y1 > y2 then
      y1 = y2
   end

   y1 = y1 + (b + 1) / 2
   y2 = y1 - b1
   a = 8 * a * a
   b1 = 8 * b * b
   
   while x1 <= x2 do
      table.insert(points, Vec2.new(x2, y1)) -- Quadrant 1
      table.insert(points, Vec2.new(x1, y1)) -- Quadrant 2
      table.insert(points, Vec2.new(x1, y2)) -- Quadrant 3
      table.insert(points, Vec2.new(x2, y2)) -- Quadrant 4

      e2 = 2 * err

      if e2 <= dy then
	 y1 = y1 + 1
	 y2 = y2 - 1
	 dy = dy + a
	 err = err + dy
      end

      if e2 >= dx or 2 * err > dy then
	 x1 = x1 + 1
	 x2 = x2 - 1
	 dx = dx + b1
	 err = err + dx
      end
   end

   while y1 - y2 < b do
      table.insert(points, Vec2.new(x1 - 1, y1))
      y1 = y1 + 1
      table.insert(points, Vec2.new(x2 + 1, y1))
      table.insert(points, Vec2.new(x1 - 1, y2))
      y2 = y2 - 1
      table.insert(points, Vec2.new(x1 + 1, y1))
   end

   return points
end
