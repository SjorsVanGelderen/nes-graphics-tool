-- Copyright 2020, Sjors van Gelderen

Vec2 = {}

function Vec2.new(x, y)
   local self = {}
   self.x = x
   self.y = y

   function self.add(other)
      return Vec2.new(self.x + other.x, self.y + other.y)
   end

   function self.sub(other)
      return Vec2.new(self.x - other.x, self.y - other.y)
   end

   function self.mul(value)
      return Vec2.new(self.x * value, self.y * value)
   end

   function self.div(value)
      return Vec2.new(self.x / value, self.y / value)
   end

   function self.mag()
      return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2))
   end

   function self.norm()
      local mag = self.mag()
      return Vec2.new(self.x / mag, self.y / mag)
   end

   function self.dot(other)
      return self.x * other.x + self.y * other.y
   end

   function self.abs()
      return Vec2.new(math.abs(self.x), math.abs(self.y))
   end
   
   function self.floor()
      return Vec2.new(math.floor(self.x), math.floor(self.y))
   end

   function self.dist(other)
      return other.sub(self).mag()
   end
   
   return self
end
