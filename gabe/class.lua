---
-- The gabe class system. The focus here is on finding the right featureset to
-- enable productive OOP. If I find something isn't that useful, I cut it.
-- Important bulletpoints:
-- * Named classes. Enabler for higher tier features.
-- * Hotswapping. Creating a new class with the same name replaces the old one.
-- * Mixins. Predictable dynamic replacement
-- * Builtin bitser support. I'd prefer a user-defined way of getting named classes but w/e
--
-- @module gabe.class
local bitser_ok, bitser = pcall(require, 'bitser')
if not bitser_ok then bitser = nil end

local class = {}

--- The global metatable container. All registered objects will have their
--  metatable stored here.
_G.MT = _G.MT or setmetatable({}, {__mode ="v"})

--- Creates a new class. If a class with this name exists, it will be replaced
--  and all existing instances of that class will point to the new class
--  instead.
--  @param name the classname.
--  @return the class table
function class.class(name)
	local mt = MT[name] or {}

	local klass = { _mt = mt }
	mt.__index = klass
	klass.new = function(...)
		local self = setmetatable({}, MT[name])
		return (klass.init and klass.init(self, ...)) or self
	end

	class.register(mt, name)

	return klass
end

--- Registers an external class by its metatable. Like class.class, it will
--  replace existing classes. It makes the assumption that all objects of a
--  single class share a metatable, same as gabe classes.
function class.register(mt, name)
	assert(mt.name == name or mt.name == nil, "mt.name already defined.")

	mt.name = name
	mt.is   = {[name] = true}

	MT[name] = mt

	if bitser then
		bitser.registerClass(name, MT[name], nil, setmetatable)
	end
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
	if MT[name] == nil then
		error(string.format("Class %q does not exist.", tostring(name)))
	end
	setmetatable(o, MT[name])
	return true
end

--- Behaves like attach, except if a name doesn't exist,
--  test to see if there is a require()able file with that name and load it.
function class.smart_attach(o, name)
	if MT[name] == nil then
		pcall(require, name)
	end
	return class.attach(o, name)
end

--- Returns the metatable associated with the given class name.
-- @param name the classname
-- @return the class metatable
-- @return nil if no such class exists
function class.get(name)
	return MT[name] and MT[name].__index
end

local function metatable(o)
	return (o and o._mt) or getmetatable(o)
end

-- class-specific things. don't override.
local skip = { new = true, _mt = true, _mixin = true, _pre_mixin = true }

--- Given two objects, "mixes in" the fields of `mixin` into the object `o`.
--  if the mixin is a class, then the object must also be a class, and the
--  mixin-process will establish an IS-A relation between the object and its
--  mixin. The relationship extends recusively, e.g. if A is mixed into B is
--  mixed into C, then C is both an A and a B.
function class.mixin(o, mixin)
	if mixin._mt then -- mixin is a class
		assert(o._mt, "Object must be a gabe class.")
		for name, _ in pairs(mixin._mt.is) do
			o._mt.is[name] = true
		end
	end

	if mixin._pre_mixin then
		mixin._pre_mixin(mixin, o)
	end

	for k, v in pairs(mixin) do
		if not skip[k] then
			if o[k] == nil then
				o[k] = v
			end
		end
	end

	if mixin._mixin then
		mixin._mixin(mixin, o)
	end

	return o
end

--- Returns whether or not the given object is an instance of the given class,
--  or if the given object's class has had the given class "mixed-in" to it.
--  Honestly, this should be has-a, but w/e.
--  @param o the object
--  @param name the class name
--  @return true
--  @return false
function class.is(o, name)
	local mt = metatable(o)

	return mt and mt.is and mt.is[name]
end

return setmetatable(class, {
	__call = function(_, ...)
		return class.class(...)
	end
})
