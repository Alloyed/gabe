-- inject gabe features into LOVE

local gabe = {}

gabe.error_handlers = require 'gabe.error_handlers'
gabe.runners = require 'gabe.runners'

function gabe.inject(release_mode)
	local state  = require 'gabe.state'

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
	if major ~= 0 then
		version_str = string.format("%d", major)
	end

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

	if version_str == "0.10" then
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
	else
		function love.run()
			state.init()
			if love.load then love.load(arg) end
			state.start()

			local runner_loop = runner()
			local error_loop = nil
			return function()
				if error_loop then
					local return_code = error_loop()
					if return_code == 0 then
						error_loop = nil
					else
						return return_code
					end
				else
					local ok, maybe = xpcall(runner_loop, debug.traceback)
					if not ok then
						local errorstring = maybe
						error_loop = error_handler(errorstring)
					else
						local return_code = maybe
						if return_code ~= nil then
							return return_code
						end
					end
				end
			end
		end
	end
end

return gabe
