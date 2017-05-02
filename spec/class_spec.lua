local class = require 'gabe.class'
local they = it

describe("classes", function()
	they("can be constructed", function()
		local K = class 'k'
		function K:method()
		end
		K.field = true
		assert.equal(type(K.method), 'function')
		assert.equal(type(K.field), 'boolean')
	end)

	they("can create objects", function()
		local K = class 'k'
		function K:init(a)
			self.a = a
		end
		assert.equal(K.new(true).a, true)
		assert.equal(K.new(false).a, false)
		assert.equal(K.new("string").a, "string")
	end)

	they("report their type", function()
		local K = class 'classname'
		local K2 = class 'classname2'
		assert.equal(class.xtype(K), 'classname')
		assert.equal(class.xtype(K2), 'classname2')
	end)

	they("can be defined externally", function()
		local a = nil
		local K = {}
		function K:thing()
			a = self.a
		end
		local mt = {__index = K}
		class.register(mt, "classname")

		local o = setmetatable({a = "hi"}, mt)
		assert.equal("classname", class.xtype(o))
		assert.truthy(class.is(o, "classname"))
		o:thing()
		assert.equal("hi", a)
	end)

	they("can be redefined", function()
		local a = nil

		local K = class 'classname'
		function K:thing()
			a = "a"
		end
		local o = K.new()
		o:thing()
		assert.equal("a", a)

		local K2 = class 'classname'
		function K2:thing()
			a = "b"
		end
		o:thing()
		assert.equal("b", a)
	end)
end)

describe("mixins", function()
	it("add fields to classes", function()
		local K = class 'K'
		local mixin = { field = "mixed-in" }
		class.mixin(K, mixin)
		assert.equal(K.field, "mixed-in")
	end)

	it("doesn't override existing fields", function()
		local K = class 'K'
		K.field = "unmixed"
		local mixin = { field = "mixed-in", field2 = "mixed-in" }
		class.mixin(K, mixin)
		assert.equal(K.field,  "unmixed")
		assert.equal(K.field2, "mixed-in")
	end)

	it("can also be classes", function()
		local K = class 'K'
		local M = class 'M'

		assert.equal(class.xtype(K), 'K')
		assert.equal(class.xtype(M), 'M')

		class.mixin(K, M)

		assert.equal(class.xtype(K), 'K')
		assert.equal(class.xtype(M), 'M')

		assert(class.xtype(K.new()), 'K')
		assert(class.xtype(M.new()), 'M')
	end)

	it("will report their mixed-in-ness when they're a class", function()
		local K = class 'K'
		local M = class 'M'
		class.mixin(K, M)
		assert.truthy(class.is(K,       'K'))
		assert.truthy(class.is(K,       'M'))
		assert.truthy(class.is(K.new(), 'K'))
		assert.truthy(class.is(K.new(), 'M'))
	end)

	it("will disallow mixing-in a class into a non-class", function()
		assert.has_errors(function()
			local K = {}
			local M = class 'M'
			class.mixin(K, M)
		end)
	end)

	it("will also report mixins that were used to make a component mixin", function()
		local K = class 'K'
		local M = class 'M'
		local N = class 'N'
		class.mixin(N, M)
		class.mixin(K, N)
		assert.truthy(class.is(K,       'K'))
		assert.truthy(class.is(K,       'M'))
		assert.truthy(class.is(K,       'N'))
		assert.truthy(class.is(K.new(), 'K'))
		assert.truthy(class.is(K.new(), 'M'))
		assert.truthy(class.is(K.new(), 'N'))
	end)
end)

describe("objects", function()
	it("have a class name", function()
		local K = class 'classname'
		assert.equal(class.xtype(K.new()), 'classname')
	end)

	it("shadow class fields", function()
		local Klass = class 'classname'
		Klass.field = "global"
		local klass = Klass.new()
		klass.field = "local"
		assert.equal(Klass.field, "global")
		assert.equal(klass.field, "local")
	end)

	it("can be created via attach()", function()
		local K = class 'classname'
		function K:check()
			assert.equal(self.a, "a")
			assert.equal(self.b, "b")
		end
		assert.has_errors(function()
			K.new():check()
		end)
		local o = {a = "a", b = "b"}
		class.attach(o, 'classname')
		o:check()
	end)
end)
