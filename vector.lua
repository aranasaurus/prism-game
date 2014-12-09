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

function Vector.isInsideHalfPlane( p, p0, dir )
    return p:subtract( p0 ):dot( dir ) >= 0
end

function Vector:turnLeft()
    return Vector:new( self.y, -self.x )
end

function Vector:turnRight()
    return Vector:new( -self.y, self.x )
end

function Vector.linesIntersect( l1, l2 )
    local s1 = l1[2]:subtract( l1[1] )
    local s2 = l2[2]:subtract( l2[1] )
    local u = l1[1]:subtract( l2[1] )

    local ip = 1 / (-s2.x * s1.y + s1.x * s2.y)

    local s = (-s1.y * u.x + s1.x * u.y) * ip
    local t = (s2.x * u.y - s2.y * u.x) * ip

    return s >= 0 and s <= 1 and t >= 0 and t <= 1
end
