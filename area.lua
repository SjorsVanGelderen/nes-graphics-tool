-- Copyright 2020, Sjors van Gelderen

require("vector2")

Area = {}

function Area.containsPoint(top_left, size, point)
   local delta = point.sub(top_left)
   
   return
      delta.x > 0 and
      delta.x < size.x and
      delta.y > 0 and
      delta.y < size.y
end

function Area.getPoint(top_left, size, point)
   local delta = point.sub(top_left)

   if delta.x > 0 and
      delta.x < size.x and
      delta.y > 0 and
      delta.y < size.y
   then
      return delta
   end
end
