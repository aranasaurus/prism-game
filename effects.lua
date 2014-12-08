require "vector"

Spark = {}

function Spark:new( pos, dir, color, length, density )
    local e = {}
    setmetatable( e, self )
    self.__index = self

    e.pos = pos:copy()
    e.dir = dir:copy()
    e.length = length or 6
    e.density = density or 12
    e.color = color or { 255, 255, 56 }
    e.alpha = 255
    e.decay = 255/30

    e.sparks = {}
    local angle = (2 * math.pi) / e.density
    for i = 1, e.density do
        local s = {
            pos = Vector:new( 0, 0 ),
            vel = e.dir:rotate( angle * i ),
        }

        e.sparks[i] = s
    end
    return e
end

function Spark:update( dt )
    self.alpha = self.alpha - self.decay
    for i, s in ipairs( self.sparks ) do
        s.pos = s.pos:add( s.vel:multiply( LASER_VEL * 0.66 * dt ) )
    end
end

function Spark:draw()
    love.graphics.push()
    love.graphics.translate( self.pos.x, self.pos.y )

    for i, s in ipairs( self.sparks ) do
        love.graphics.push()

        love.graphics.setColor( self.color[1], self.color[2], self.color[3], self.alpha )
        local l = s.vel:multiply( self.length )
        local p1 = s.pos:subtract( l )
        local p2 = s.pos:add( l )
        love.graphics.line( p1.x, p1.y, p2.x, p2.y )

        love.graphics.pop()
    end

    love.graphics.pop()
end
