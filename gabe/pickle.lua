local class = require 'gabe.class'

local function set(...)
	local t = {}
	for i=1, select('#', ...) do
		t[select(i, ...)] = true
	end
	return t
end

--- A Pickler factory.
-- To use in your application, make a module that does nothing but make a
-- pickler and return it so configuration is stored in a single place.
--
-- @param encode a function that returns its input serialized to a string
--
-- @param decode a function that takes encode() serialized strings and returns
-- the lua data they represent.
return function(encode, decode)
	if not encode then
		local json = require 'dkjson'
		encode, decode = json.encode, json.decode
	end
	local pickle = {}

	local valid = set("string", "table", "number", "boolean", "nil")

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

	function pickle.check(obj, checked)
		checked = checked or {}
		local t = type(obj)
		if t == 'table' then
			for k, v in pairs(obj) do
				-- TODO: check keys
				local ok, err = pickle.check(v)
				if not ok then
					local emsg = "invalid value in %s[%s]: %s"
					return false, emsg:format(tostring(obj), tostring(k), err)
				end
			end
		end

		if not valid[t] then
			local emsg = "invalid datatype %s(%s)"
			return false, emsg:format(tostring(t), tostring(obj))
		end

		return true
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
		local data = assert(decode(str))
		return pickle.unpickle(data)
	end

	function pickle.to_file(fname, obj)
		local data = pickle.pickle(obj)
		local str = assert(encode(data))
		local dir = fname:match("^(.+)/[^/]*$")
		if dir then
			love.filesystem.createDirectory(dir)
		end
		assert(love.filesystem.write(fname, str))
		return true
	end

	function pickle.to_string(obj)
		local data = pickle.pickle(obj)
		return encode(data)
	end

	function pickle.from_string(str)
		local data = assert(decode(str))
		return pickle.unpickle(data)
	end

	return pickle
end
