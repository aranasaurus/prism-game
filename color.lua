Color = {}

function Color:new( r, g, b, a, name )
    local c = {}
    setmetatable( c, self )
    self.__index = self

    c.r, c.g, c.b, c.a, c.name = r, g, b, a, name
    return c
end

function Color:toCMYK()
    local cmyk = { c = 0, y = 0, m = 0, k = 0 }

    cmyk.c = 255 - self.r
    cmyk.m = 255 - self.g
    cmyk.y = 255 - self.b
    cmyk.k = math.min( cmyk.c, cmyk.m, cmyk.y )

    cmyk.c = ((cmyk.c - cmyk.k) / (255 - cmyk.k))
    cmyk.m = ((cmyk.m - cmyk.k) / (255 - cmyk.k))
    cmyk.y = ((cmyk.y - cmyk.k) / (255 - cmyk.k))
    cmyk.k = cmyk.k/255

    return cmyk
end

function Color.combine( first, second )
    -- Convert both to CMYK
    local c1 = first:toCMYK()
    local c2 = second:toCMYK()

    -- Combine them
    local cmyk = {
        c = (c1.c + c2.c) / 2,
        m = (c1.m + c2.m) / 2,
        y = (c1.y + c2.y) / 2,
        k = (c1.k + c2.k) / 2,
    }

    -- Convert them back to rgba
    local r = cmyk.c * (1 - cmyk.k) + cmyk.k
    local g = cmyk.m * (1 - cmyk.k) + cmyk.k
    local b = cmyk.y * (1 - cmyk.k) + cmyk.k
    r = math.ceil( (1 - r) * 255 )
    g = math.ceil( (1 - g) * 255 )
    b = math.ceil( (1 - b) * 255 )

    return Color:new( r, g, b, math.max( first.a or 255, second.a or 255 ) )
end

function Color:toarray()
    return { self.r, self.g, self.b, self.a }
end

function Color:copy()
    return Color:new( self.r, self.g, self.b, self.a, self.name )
end
