local handlers = {}

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

local function color(r, g, b, a)
	return r / 255, g / 255, b / 255, (a or 255) / 255
end

local function oldcolor(r, g, b, a)
	return r, g, b, a
end

local errorscreen = {}

function errorscreen:clear()
	self.buffer = {}
	self.bufferDirty = true
end

function errorscreen:add(...)
	for i=1, select('#', ...) do
		local line = select(i, ...)
		table.insert(self.buffer, line)
	end
	self.bufferDirty = true
end

function errorscreen:getBufferText()
	if self.bufferDirty then
		self.bufferDirty = false
		self.bufferText = table.concat(self.buffer, "\n")
	end
	return self.bufferText
end

function errorscreen:newError(msg)
	local utf8 = require("utf8")

	love.graphics.reset()
	love.graphics.setNewFont(14)

	love.graphics.setColor(color(255, 255, 255, 255))

	love.graphics.origin()

	msg = msg:gsub("\t", ""):gsub("%[string \"(.-)\"%]", "%1"):gsub("stack traceback:", "\nTraceback\n")
	local lines = {}
	for l in string.gmatch(msg, "(.-)\n") do
		-- cut off at framework level code to keep tracebacks user-relevant
		if string.match(l, "gabe/runners") then
			break
		end
		table.insert(lines, l)
	end
	msg = table.concat(lines, "\n")

	error_printer(msg, 2)

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	self:clear()
	self:add("Error:", "", sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		self:add("Invalid UTF-8 string in error message.")
	end

	if love.system then
		self:add("", "", "Press Ctrl+C or tap to copy this error")
	end

	self:add("", "", "Gabe: Press r to reload, shift-R to restart")
end

function errorscreen:draw()
	local bufferText = self:getBufferText()
	local pos = 70
	love.graphics.clear(color(89, 157, 220))
	love.graphics.printf(bufferText, pos, pos, love.graphics.getWidth() - pos)
	love.graphics.present()
end

function errorscreen:reload()
	local reload = require 'gabe.reload'
	reload.reload_all()
end

function errorscreen:reloadAndReset()
	local reload = require 'gabe.reload'
	local state  = require 'gabe.state'
	reload.reload_all()
	state.reset()
end

function errorscreen:copyToClipboard()
	if not love.system then return end
	local bufferText = self:getBufferText()
	love.system.setClipboardText(bufferText)
	self:add("Copied to clipboard!")
end

function errorscreen:tryQuit()
	local name = love.window.getTitle()
	if #name == 0 or name == "Untitled" then name = "Game" end
	local buttons = {"OK", "Cancel"}
	if love.system then
		buttons[3] = "Copy to clipboard"
	end
	local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
	if pressed == 1 then
		return true
	elseif pressed == 3 then
		self:copyToClipboard()
	end

	return false
end

handlers["11"] = function(msg) -- {{{
	msg = tostring(msg)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	errorscreen:newError(msg)

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				errorscreen:copyToClipboard()
			elseif e == "textinput" and a == "r" then
				errorscreen:reload()
				return 0
			elseif e == "textinput" and a == "R" then
				errorscreen:reloadAndReset()
				return 0
			elseif e == "touchpressed" and errorscreen:tryQuit() then
				return 1
			elseif e == "repler" then
				love.handlers.repler(a)
			end
		end

		errorscreen:draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end -- }}}

handlers["0.10"] = function(msg) -- {{{
	color = oldcolor
	msg = tostring(msg)

	print(msg)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isCreated() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	love.graphics.setNewFont(math.floor(love.window.toPixels(14)))
	love.graphics.setColor(color(255, 255, 255))
	love.graphics.clear()
	love.graphics.origin()

	errorscreen:newError(msg)

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return false
			end
			if e == "keypressed" and a == "escape" then
				return false
			end
			if e == "textinput" and a == "r" then
				errorscreen:reload()
				return true
			end

			if e == "textinput" and a == "R" then
				errorscreen:reloadAndReset()
				return true
			end
			if e == "repler" then
				love.handlers.repler(a)
			end
		end

		errorscreen:draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end -- }}}

return handlers
