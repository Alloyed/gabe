-- Gabe functions by monkey-patching the love table, and should be called 
-- first.
require 'gabe' ()
-- Gabe.state is the state management libraries
local state  = require 'gabe.state'
-- Gabe.reload provides functions to reload code
local reload = require 'gabe.reload'
-- Gabe.class provides a simple, reload-friendly class implementation
local class  = require 'gabe.class'

-- An example class.
------------------------------------------------------------------------------

-- in Gabe, all classes _must_ be named. When a game is reloaded, objects will
-- swap out their old classes for new ones with the same name.
local Dot = class 'dot'

-- This means that class-level fields can be changed. If you change Dot.radius
-- here, and reload the game, all dots will reflect the new radius value.
Dot.radius = 20

-- Dot:init() is a constructor. It will only be called once, when an object is
-- first created, so changing init() and reloading will only affect new dots,
-- not old ones.
function Dot:init(x, y)
	self.x, self.y = x, y
end

-- Dot:draw() is a normal method. it can get reloaded and replaced, just like
-- Dot.radius.
function Dot:draw()
	love.graphics.circle('fill', self.x, self.y, self.radius)
end

-------------------------------------------------------------------------------


-- Game lifecycle functions. Use these to set up and tear down game state as
-- necessary.
-------------------------------------------------------------------------------

-- Happens only once, at the very beginning
function love.load()
	print("Game loaded")
end

-- Happens on once, at the very end
function love.quit()
	print("Game quit")
end

-- Happens on love.quit, and in between resets
function state.stop()
end

-- Happens on love.load, and in between resets
function state.start()
	local w, h = love.graphics.getDimensions()
	S.dots = {}
	for i=1, 3 do
		local dot = Dot.new(math.random(w), math.random(h))
		table.insert(S.dots, dot)
	end
end

-------------------------------------------------------------------------------

-- LOVE callbacks. you should recognize these.
-------------------------------------------------------------------------------
function love.draw()
	for _, d in ipairs(S.dots) do
		d:draw()
	end
end

function love.keypressed(k)
	if k == '1' then
		-- This reloads the game's code, to reflect changes you have made.
		reload.reload_all()
		print("reloaded")
	elseif k == '2' then
		-- This resets the game's state. This is usually faster than closing
		-- and re-opening your game, and can be used throughout testing.
		-- NOTE: resetting your game does not automatically reload the game,
		-- so you should do both to fully reflect changes.
		state.reset()
		print("reset")
	elseif k == '3' then
		-- pressing '3' will trigger an error, which you can recover from by
		-- reseting/reloading the game. This is useful for fixing mistakes.
		error("reload me!")
	end
end
-------------------------------------------------------------------------------
