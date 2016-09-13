-- State managment

local state = {}

--- replaceme
function state.stop()
end

--- replaceme
function state.start()
end

function state.reset()
	state.stop()
	_G.C, _G.S = nil, nil
	collectgarbage("collect")
	state.init()
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
	_G.S  = _G.S  or {}           -- game state
end

return state
