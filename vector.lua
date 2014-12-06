Vector = {}

function Vector:new( x, y )
    local v = {}
    setmetatable( v, self )
    self.__index = self

    v.x, v.y = x, y
    return v
end

function Vector:translateBy( other )
    self.x = self.x + other.x
    self.y = self.y + other.y
end

function Vector:scaleBy( scl )
    self.x = self.x * scl
    self.y = self.y * scl
end

function Vector:length()
    return math.sqrt( self:lengthsq() )
end

function Vector:lengthsq()
    return self.x * self.x + self.y * self.y
end

function Vector:normalized()
    return Vector:new( self:scale( 1/self:length() ) )
end

function Vector:angle()
    return math.atan2( self.y, self.x )
end
