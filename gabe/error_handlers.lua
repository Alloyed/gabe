local handlers = {}

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

handlers["11"] = function(msg) -- {{{
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
	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))

	local sRGB = select(3, love.window.getMode()).srgb
	local rgb_f = function(...) return ... end
	if sRGB and love.math then
		rgb_f = love.math.gammaToLinear
	end

	love.graphics.setColor(255, 255, 255)

	love.graphics.clear()
	love.graphics.origin()

	local err = {}

	table.insert(err, "Error\n")

	for l in string.gmatch(msg, "(.-)\n") do
		if string.match(l, "gabe/runners") then
			break
		end
		l = string.gsub(l, "stack traceback:", "\nTraceback\n")
		table.insert(err, l)
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.clear(rgb_f(89, 157, 220))
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.print("Gabe framework, press (r) to reload, (R) to restart", 0, 0)
		love.graphics.present()
	end

	local reload = require 'gabe.reload'
	local state  = require 'gabe.state'
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
				reload.reload_all()
				return true
			end

			if e == "textinput" and a == "R" then
				reload.reload_all()
				state.reset()
				return true
			end
			if e == "repler" then
				love.handlers.repler(a)
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
	return false
end -- }}}

handlers["0.10"] = function(msg) -- {{{
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
	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))

	local sRGB = select(3, love.window.getMode()).srgb
	local rgb_f = function(...) return ... end
	if sRGB and love.math then
		rgb_f = love.math.gammaToLinear
	end

	love.graphics.setColor(255, 255, 255)

	love.graphics.clear()
	love.graphics.origin()

	local err = {}

	table.insert(err, "Error\n")

	for l in string.gmatch(msg, "(.-)\n") do
		if string.match(l, "gabe/runners") then
			break
		end
		l = string.gsub(l, "stack traceback:", "\nTraceback\n")
		table.insert(err, l)
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.clear(rgb_f(89, 157, 220))
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.print("Gabe framework, press (r) to reload, (R) to restart", 0, 0)
		love.graphics.present()
	end

	local reload = require 'gabe.reload'
	local state  = require 'gabe.state'
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
				reload.reload_all()
				return true
			end

			if e == "textinput" and a == "R" then
				reload.reload_all()
				state.reset()
				return true
			end
			if e == "repler" then
				love.handlers.repler(a)
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
	return false
end -- }}}

return handlers
