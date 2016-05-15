-- inject gabe features into LOVE

local gabe = {}

gabe.error_handlers = require 'gabe.error_handlers'
gabe.runners = require 'gabe.runners'

--function gabe.inject()
--	local state  = require 'gabe.state'
--	if love._user then
--		state.init()
--		return
--	end
--
--	local reload = require 'gabe.reload'
--	love._user = {}
--
--	love._system = setmetatable({}, {__index = love._user})
--	love._system.load = function(args)
--		state.init()
--		state.newA()
--		if love._user.load then
--			love._user.load(args)
--		end
--		state.start()
--	end
--	love.errhand = nil
--	local major, minor = love._version_major, love._version_minor
--	local version_str = string.format("%d.%d", major, minor)
--	local err = gabe.error_handlers[version_str]
--	assert(err ~= nil, "Error handler for " .. version_str .. " not found")
--
--	love._system.errhand = err
--	love = setmetatable(love, {
--		__index = love._system,
--		__newindex = love._user,
--	})
--	return true
--end

function gabe.inject()
	local major, minor = love._version_major, love._version_minor
	local version_str = string.format("%d.%d", major, minor)

	local state  = require 'gabe.state'
	if love._user then
		state.init()
		return
	end

	-- where user callbacks go
	love._user = {}
	love = setmetatable(love, {
		__index = love._user,
		__newindex = love._user
	})

	love.load = nil

	local runner        = gabe.runners[version_str]
	local error_handler = gabe.error_handlers[version_str]
	if runner == nil or error_handler == nil then
		error("Missing custom framework for " .. version_str)
	end

	function love.run()
		state.init()
		if love.load then love.load(arg) end
		state.start()

		local cont = true
		while cont do
			local ok, err = xpcall(runner, debug.traceback)
			if not ok then
				cont = error_handler(err)
			else
				return
			end
		end
	end
end

return gabe
