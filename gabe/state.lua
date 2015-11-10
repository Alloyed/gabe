-- State managment

local state = {}

--- replaceme
function state.stop()
end

--- replaceme
function state.start()
end

-- replaceme
function state.newA()
end

function state.reset()
	state.stop()
	S = {}
	collectgarbage("collect")
	state.start()
end

local function C_index(t, k)
	rawset(t, k, {})
	return rawget(t, k)
end

function state.newC()
	return setmetatable({}, {__mode = 'k', __index = C_index})
end

function state.init()
	_G.C  = _G.C  or state.newC() -- cache
	_G.A  = state.newA(_G.A)      -- assets
	_G.S  = _G.S  or {} -- game state
end

return state
