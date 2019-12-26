-- State managment

local state = {}

state.stateName = "S"
state.cacheName = "C"
function state.setGlobalNames(stateName, cacheName)
	state.stateName = stateName or "S"
	state.cacheName = cacheName or "C"
end

--- replaceme
function state.stop()
end

--- replaceme
function state.start()
end

function state.reset()
	state.stop()
	_G[state.stateName] = nil
	_G[state.cacheName] = nil
	collectgarbage("collect")
	state.init()
	state.start()
end

local function cache_index(t, k)
	rawset(t, k, {})
	return rawget(t, k)
end

function state.newCache()
	return setmetatable({}, {__mode = 'k', __index = cache_index})
end

function state.init()
	_G[state.stateName]  = _G[state.stateName]  or {}
	_G[state.cacheName]  = _G[state.cacheName]  or state.newCache()
end

return state
