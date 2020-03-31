-- Copyright 2020, Sjors van Gelderen

function constrain(x, lower, upper)
   local value = x

   if value < lower then
      value = lower
   elseif value > upper then
      value = upper
   end

   return value
end
