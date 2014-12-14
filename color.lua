Color = {}

function Color:new( r, g, b, a, name )
    local c = {}
    setmetatable( c, self )
    self.__index = self

    if type( r ) == "string" then
        return self.colors[r]:copy()
    end

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
    if first.name == second.name then
        local c = first:copy()
        c.a = math.min( 255, first.a + second.a )
        return c
    else
        if first.name == "red" then
            if second.name == "yellow" then
                return Color.colors.orange:copy()
            elseif second.name == "blue" then
                return Color.colors.purple:copy()
            end
        elseif first.name == "yellow" then
            if second.name == "red" then
                return Color.colors.orange:copy()
            elseif second.name == "blue" then
                return Color.colors.green:copy()
            end
        elseif first.name == "blue" then
            if second.name == "yellow" then
                return Color.colors.green:copy()
            elseif second.name == "red" then
                return Color.colors.purple:copy()
            end
        end
    end

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

Color.colors = {
    red = Color:new( 255, 0, 0, 255, "red" ),
    yellow = Color:new( 255, 255, 0, 255, "yellow" ),
    orange = Color:new( 255, 150, 60, 255, "orange" ),
    blue = Color:new( 0, 100, 255, 255, "blue" ),
    purple = Color:new( 190, 40, 255, 255, "purple" ),
    green = Color:new( 0, 255, 0, 255, "green" ),
    white = Color:new( 255, 255, 255, 255, "white" ),
    black = Color:new( 0, 0, 0, 255, "black" )
}

