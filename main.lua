require 'gabe' ()
local state  = require 'gabe.state'
local reload = require 'gabe.reload'
local class  = require 'gabe.class'

local lg = require 'love.graphics'

-- An example class.
------------------------------------------------------------------------------

local Dot = class 'dot'
Dot.r = 20

function Dot:init(x, y)
	self.x, self.y = x, y
end

function Dot:draw()
	love.graphics.circle('fill', self.x, self.y, self.r)
end

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
		table.insert(S.dots, Dot.new(math.random(w), math.random(h)))
	end
end

function love.draw()
	for _, d in ipairs(S.dots) do
		d:draw()
	end
end

function love.keypressed(k)
	if k == '1' then
		reload.reload_all()
		print("reloaded")
	elseif k == '2' then
		state.reset()
		print("reset")
	elseif k == '3' then
		wat()
	end
end
