Vector = {}

function Vector:new( x, y )
    local v = {}
    setmetatable( v, self )
    self.__index = self

    v.x, v.y = x, y
    return v
end

function Vector:add( other )
    self.x = self.x + other.x
    self.y = self.y + other.y
end

function Vector:subtract( other )
    self.x = self.x - other.x
    self.y = self.y - other.y
end

function Vector:addCopy( other )
    return Vector:new( self.x + other.x, self.y + other.y )
end

function Vector:subtractCopy( other )
    return Vector:new( self.x - other.x, self.y - other.y )
end

function Vector:multiply( scl )
    self.x = self.x * scl
    self.y = self.y * scl
end

function Vector:multiplyCopy( scl )
    return Vector:new( self.x * scl, self.y * scl )
end

function Vector:length()
    return math.sqrt( self:lengthsq() )
end

function Vector:lengthsq()
    return self.x * self.x + self.y * self.y
end

function Vector:normalized()
    if self:length() == 0 then
        return Vector:new( 0, 0 )
    end

    local n = self:multiplyCopy( 1 / self:length() )
    return Vector:new( n.x, n.y )
end

function Vector:angle()
    return math.atan2( self.y, self.x )
end

function Vector:dot( other )
    return self.x * other.x + self.y * other.y
end

function Vector:reflect( other )
    local velNorm = other:multiplyCopy( self:dot( other ) )
    velNorm:multiply( 2 )
    self:subtract( velNorm )
end
