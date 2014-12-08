Vector = {}

function Vector:new( x, y )
    local v = {}
    setmetatable( v, self )
    self.__index = self

    v.x, v.y = x, y
    return v
end

function Vector:copy()
    return Vector:new( self.x, self.y )
end

function Vector:add( other )
    return Vector:new( self.x + other.x, self.y + other.y )
end

function Vector:subtract( other )
    return Vector:new( self.x - other.x, self.y - other.y )
end

function Vector:multiply( scl )
    return Vector:new( self.x * scl, self.y * scl )
end

function Vector:length()
    return math.sqrt( self:lengthsq() )
end

function Vector:lengthsq()
    return self.x * self.x + self.y * self.y
end

function Vector:normalize()
    local l = self:length()
    if l == 0 then
        return Vector:new( 0, 0 )
    end

    return self:multiply( 1/l )
end


function Vector:angle()
    return math.atan2( self.y, self.x )
end

function Vector:dot( other )
    return self.x * other.x + self.y * other.y
end

function Vector:reflect( other )
    local velNorm = other:multiply( self:dot( other ) )
    velNorm = velNorm:multiply( 2 )
    return self:subtract( velNorm )
end

function Vector:rotate( angle )
    local cosa = math.cos( angle )
    local sina = math.sin( angle )
    local r = self:copy()

    r.x = self.x * cosa - self.y * sina
    r.y = self.x * sina + self.y * cosa

    return r
end
