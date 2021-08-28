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

    cmyk.c = 1 - self.r
    cmyk.m = 1 - self.g
    cmyk.y = 1 - self.b
    cmyk.k = math.min( cmyk.c, cmyk.m, cmyk.y )

    if cmyk.k == 1 then
        cmyk.c = 0
        cmyk.m = 0
        cmyk.y = 0
    else
        cmyk.c = ((cmyk.c - cmyk.k) / (1 - cmyk.k))
        cmyk.m = ((cmyk.m - cmyk.k) / (1 - cmyk.k))
        cmyk.y = ((cmyk.y - cmyk.k) / (1 - cmyk.k))
    end

    return cmyk
end

function Color.combine( first, second )
    if first.name == second.name then
        local c = first:copy()
        c.a = math.min( 1, first.a + second.a )
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
    r = math.ceil( 1 - r )
    g = math.ceil( 1 - g )
    b = math.ceil( 1 - b )

    return Color:new( r, g, b, math.max( first.a or 1, second.a or 1 ) )
end

function Color:toarray()
    return { self.r, self.g, self.b, self.a }
end

function Color:copy()
    return Color:new( self.r, self.g, self.b, self.a, self.name )
end

Color.colors = {
    red = Color:new( 221/255, 50/255, 50/255, 1, "red" ),
    yellow = Color:new( 1, 221/255, 0, 1, "yellow" ),
    orange = Color:new( 1, 115/255, 10/255, 1, "orange" ),
    blue = Color:new( 0, 115/255, 1, 1, "blue" ),
    purple = Color:new( 170/255, 0, 1, 1, "purple" ),
    green = Color:new( 50/255, 215/255, 50/255, 1, "green" ),
    white = Color:new( 1, 1, 1, 1, "white" ),
    black = Color:new( 0, 0, 0, 1, "black" )
}

