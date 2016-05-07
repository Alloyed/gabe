local class = {}

_G.MT = _G.MT or {} -- metatables

local function _tostring(t)
	return class.xtype(t)
end

--- Creates a new class. If a class with this name exists, it will be replaced
--  and all existing instances of that class will point to the new class
--  instead.
--  @param name the classname.
--  @return the class table
function class.class(name)
	MT[name] = MT[name] or {name = name}
	local class = { _mt = MT[name] }
	MT[name].is = { [name] = true }
	MT[name].__index = class
	class.new = function(...)
		local self = setmetatable({}, MT[name])
		return (class.init and class.init(self, ...)) or self
	end
	return class
end

--- Returns the given object's canonical class name. Where possible, try to use
--  class.is() instead.
--  @param o the object
--  @return the object's class name
function class.xtype(o)
	if o._mt then return o._mt.name end
	local mt = getmetatable(o)
	return mt and mt.name
end

--- Turns a given object "into" the class with the given name. More precisely,
--  it sets it metatable as if it were created using `class.new(name)`
--  @param o the object
--  @param name the class name
function class.attach(o, name)
	local msg = string.format("Class %q does not exist.", tostring(name))
	assert(MT[name] ~= nil, msg)
	setmetatable(o, MT[name])
	return true
end

--- Returns the metatable associated with the given class name.
-- @param name the classname
-- @return the class metatable
-- @return nil if no such class exists
function class.get(name)
	return MT[name] and MT[name].__index
end

--- Returns whether or not the given object contains the keys the interface
--  contains.
--  This provides a reasonable facsimile of the keyword "implements" in
--  traditional OO languages.
--  @param o the object to test
--  @param interface a table where each non-nil key/value pair corresponds to
--  an expected property.
--  @return true
--  @return false, error_message
function class.contains(o, interface)
	if o == nil then
		return false, "Object is nil"
	end
	for k, _ in pairs(interface) do
		if o[k] == nil then
			local so, sk = tostring(o), tostring(sk)
			return false, string.format("%q missing property %q", so, sk)
		end
	end
	return true
end

local function juxt(...)
	local fns = {...}
	return function(...)
		local r = {}
		for _, f in ipairs(fns) do
			local tmp = {f(...)}
			if tmp[1] then
				r = tmp
			end
		end
		return unpack(r)
	end
end

local function mt(o)
	return (o and o._mt) or getmetatable(o)
end

-- class-specific things. don't override.
local skip = { new = true, _mt = true }
function class.mixin(o, mixin)
	for k, v in pairs(mixin) do
		if not skip[k] then
			if o[k] == nil then
				o[k] = v
			elseif type(o[k]) == 'function' then
				o[k] = juxt(o[k], v)
			end
		end
	end
	local xt = class.xtype(mixin)
	if xt then
		mt(o).is[xt] = true
	end
	return o
end

--- Returns whether or not the given object is an instance of the given class.
--  @param o the object
--  @param name the class name
--  @return true
--  @return false
function class.is(o, name)
	local mt = mt(o)

	return mt and mt.is and mt.is[name]
end

local fn = class.class("function-ref")
MT['function-ref'].__call = function(self, ...)
	return package.loaded[self.pkg][self.name](...)
end

function fn:init(pkg, name)
	self.pkg = pkg
	self.name = name
end

--- Returns a callable object, that can be used to refer to functions in a
--  serializable way.
--      class.fn("my-module", "my_function") (...)
--  is equivalent to
--      require("my-module").my_function(...)
--  @param pkg the module the function is owned by.A
--  @param name the name of the function
--  @return a callable ref
function class.fn(pkg, name)
	return fn.new(pkg, name)
end

local method = class.class("method-ref")
MT['method-ref'].__call = function(self, ...)
	return self.object[self.method](self.object, ...)
end

function method:init(o, m)
	self.object = o
	self.method = m
end

--- Returns a callable object, that can be used to refer to a class's methods
--      class.method(obj, "method") (...)
--  is equivalent to
--      obj:method(...)
--  @param obj the object
--  @param name the method name
--  @return the method ref
function class.method(obj, name)
	return method.new(obj, name)
end

return setmetatable(class, {
	__call = function(t, ...)
		return class.class(...)
	end
})
