local Baz = require(script.Parent.Baz)
local Boo = require(script.Parent.Boo)

local Foo = {}
Foo.__index = Foo

function Foo.new()
    return setmetatable({
        Bar = 42,
        Baz = Baz.new(),
        Boos = {
            Top = Boo.new(),
            Botttom = Boo.new(),
            Left = Boo.new(),
            Right = Boo.new(),
        },
    }, Foo)

    return Foo
