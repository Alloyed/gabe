local safe = {
	["coroutine"] = true,
	["love.graphics"] = true,
	["io"] = true,
	["love.audio"] = true,
	["jit"] = true,
	["love.mouse"] = true,
	["love.image"] = true,
	["love.filesystem"] = true,
	["bit"] = true,
	["jit.util"] = true,
	["love.math"] = true,
	["love.font"] = true,
	["jit.opt"] = true,
	["love.window"] = true,
	["love.event"] = true,
	["love.sound"] = true,
	["love.joystick"] = true,
	["love.boot"] = true,
	["love.physics"] = true,
	["package"] = true,
	["love.timer"] = true,
	["love"] = true,
	["math"] = true,
	["_G"] = true,
	["os"] = true,
	["love.keyboard"] = true,
	["love.thread"] = true,
	["string"] = true,
	["debug"] = true,
	["love.system"] = true,
	["table"] = true,
	["conf"] = true,
	["ffi"] = true,

	-- custom
	["rocks"] = true,
	["repler"] = true,
	["reload"] = true,
	["love-watch"] = true,
	["love-watch.watcher"] = true,
	["love-gamepad"] = true,
	["love-gamepad.gamepad"] = true,
	["love-gamepad.data"] = true,
	--["strict"] = true,
}

local reload = {}

function reload.reload(mod)
	package.loaded[mod] = nil
	return require(mod)
end

function reload.reload_all()
	for modname, mod in pairs(package.loaded) do
		if not safe[modname] then
			package.loaded[modname] = nil
		end
	end
	require 'main'
end

function reload.save_modules()
	for modname, mod in pairs(package.loaded) do
		safe[modname] = true
	end
end

function reload.add_modules(...)
	for i=1, select('#', ...) do
		local n = select(i, ...)
		safe[n] = true
	end
end

return reload
