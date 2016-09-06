-- inject gabe features into LOVE

local gabe = {}

gabe.error_handlers = require 'gabe.error_handlers'
gabe.runners = require 'gabe.runners'

function gabe.inject(release_mode)
	if release_mode then
		local love_run = love.run
		function love.run()
			state.init()
			if love.load then love.load(arg) love.load = nil end
			state.start()
			return love_run()
		end
		return
	end

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
