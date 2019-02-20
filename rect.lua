local class = require 'gabe.class'

-- in Gabe, all classes _must_ be named. When a game is reloaded, objects will
-- swap out their old classes for new ones with the same name.
local Rect = class('rect')

-- This means that class-level fields can be changed. If you change Rect.radius
-- here, and reload the game, all rects will reflect the new radius value.
Rect.side = 20

-- Rect:init() is a constructor. It will only be called once, when an object is
-- first created, so changing init() and reloading will only affect new rects,
-- not old ones.
function Rect:init(x, y)
	self.x, self.y = x, y
end

-- Rect:draw() is a normal method. it can get reloaded and replaced, just like
-- Rect.radius.
function Rect:draw()
	love.graphics.rectangle('fill', self.x, self.y, self.side*2, self.side)
end

return Rect
