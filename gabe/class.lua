local class = {}

_G.MT = _G.MT or {} -- metatables

local function _tostring(t)
	return class.xtype(t)
end

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

function class.xtype(o)
	if o._mt then return o._mt.name end
	local mt = getmetatable(o)
	return mt and mt.name
end

function class.attach(o, name)
	local msg = string.format("Class %q does not exist.", tostring(name))
	assert(MT[name] ~= nil, msg)
	setmetatable(o, MT[name])
	return true
end

function class.get(name)
	return MT[name] and MT[name].__index
end

function class.contains(o, interface)
	assert(o ~= nil, "Class is nil")
	for k, _ in pairs(interface) do
		assert(o[k], string.format("%q missing property %q", tostring(o), tostring(k)))
	end
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

function class.is(o, name)
	local mt = mt(o)

	return mt and mt.is and mt.is[name]
end

return setmetatable(class, {
	__call = function(t, ...)
		return class.class(...)
	end
})
