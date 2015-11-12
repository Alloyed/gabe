local class = require 'gabe.class'
local json  = require 'dkjson'
local bump  = require 'bump'
local x     = require 'misc'
local pickle = {}

local valid = x.set("string", "table", "number", "boolean", "nil")

function pickle.pickle(obj)
	local t = type(obj)
	if t == 'table' then
		local nobj = {}
		for k, v in pairs(obj) do
			nobj[k] = pickle.pickle(v)
		end

		local xt = class.xtype(obj)
		if xt then
			nobj.xtype = xt
		end

		return nobj
	end

	assert(valid[t], "Invalid data type: " .. tostring(t))
	return obj
end

function pickle.unpickle(obj)
	local t = type(obj)
	if t == 'table' then
		local x = obj.xtype
		if x then
			obj.xtype = nil
			for k, v in pairs(obj) do
				obj[k] = pickle.unpickle(v)
			end
			class.attach(obj, x)
		else
			for k, v in pairs(obj) do
				obj[k] = pickle.unpickle(v)
			end
		end
	end

	return obj
end

-- deep copy
function pickle.copy(obj)
	local r = {}
	for k, v in pairs(obj) do
		if type(v) == 'table' then
			r[k] = pickle.copy(v)
		else
			r[k] = v
		end
	end
	setmetatable(r, getmetatable(obj))
	return r
end

function pickle.from_file(fname)
	local str, err = love.filesystem.read(fname)
	assert(str, tostring(fname) .. ": " .. err)
	local data = assert(json.decode(str))
	return pickle.unpickle(data)
end

function pickle.to_file(fname, obj)
	local data = pickle.pickle(obj)
	local str = assert(json.encode(data))
	local dir = fname:match("^(.+)/[^/]*$")
	if dir then
		love.filesystem.createDirectory(dir)
	end
	assert(love.filesystem.write(fname, str))
	return true
end

return pickle
