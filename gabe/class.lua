local class = {}

_G.MT = _G.MT or {} -- metatables

local function _tostring(t)
	return class.xtype(t)
end

function class.class(name)
	local class = {}
	MT[name] = MT[name] or {name = name}
	MT[name].__index = class
	--MT[name].__tostring = _tostring
	class.new = function(...)
		local self = setmetatable({}, MT[name])
		return (class.init and class.init(self, ...)) or self
	end
	return class
end

function class.xtype(o)
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

function class.mixin(o, mixin)
	for k, v in pairs(mixin) do
		if type(o[k]) == 'function' then
			if k ~= "new" then
				o[k] = juxt(o[k], v)
			end
		else
			o[k] = v
		end
	end
	return o
end

return setmetatable(class, {
	__call = function(t, ...)
		return class.class(...)
	end
})
