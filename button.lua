-- -- Copyright 2020, Sjors van Gelderen

-- require("area")
-- require("vector2")

-- local graphics = love.graphics
-- local image = love.image
-- local mouse = love.mouse

-- Button = {}

-- function Button.new(pos, size, caption, icon, action)
--    local self = {}
--    self.pos = pos
--    self.size = size
--    self.caption = caption
--    self.action = action

--    if icon ~= nil then
--       self.icon = graphics.newImage(icon)
--    end

--    function self.press()
--       local mx, my = mouse.getPosition()
--       local mp = Vec2.new(mx, my)

--       if Area.containsPoint(self.pos, self.size, mp) then
-- 	 action()
-- 	 return true
--       end

--       return false
--    end

--    function self.draw()
--       if image == nil then
-- 	 graphics.setColor(186 / 255, 190 / 255, 195 / 255)
-- 	 graphics.rectangle("fill", self.pos.x, self.pos.y, self.size.x, self.size.y)
--       else
-- 	 graphics.setColor(1, 1, 1)
-- 	 graphics.draw(self.icon, self.pos.x, self.pos.y)
--       end

--       if caption ~= nil then
-- 	 graphics.print(self.caption, self.pos.x, self.pos.y)
--       end
      
--       graphics.setColor(1, 0, 1, 1)
--    end

--    return self
-- end
