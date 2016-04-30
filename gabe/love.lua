-- inject gabe features into LOVE

local gabe = {}

gabe.error_handlers = require 'gabe.error_handlers'

function gabe.inject()
	local state  = require 'gabe.state'
	if love._user then
		state.init()
		return
	end

	local reload = require 'gabe.reload'
	love._user = {}

	love._system = setmetatable({}, {__index = love._user})
	love._system.load = function(args)
		state.init()
		state.newA()
		if love._user.load then
			love._user.load(args)
		end
		state.start()
	end
	love.errhand = nil
	local err = gabe.error_handlers[version_str]
	if err ~= nil then
		local major, minor = love._version_major, love._version_minor
		local version_str = string.format("%d.%d", major, minor)
		error("Error handler for " .. version_str .. " not found")
	end

	love._system.errhand = err
	love = setmetatable(love, {
		__index = love._system,
		__newindex = love._user,
	})
	return true
end

return gabe
