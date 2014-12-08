require "vector"

Laser = {}

function Laser:new( pos, dir )
    local l = {}
    setmetatable( l, self )
    self.__index = self

    l.pos = pos:copy()
    l.dir = dir:copy()
    l.vel = dir:normalized()
    l.w = 24
    l.h = 4

    return l
end

function Laser:draw()
    love.graphics.push()
    love.graphics.translate( self.pos.x, self.pos.y )
    love.graphics.rotate( self.dir:angle() )

    love.graphics.setColor( 64, 255, 64 )
    love.graphics.rectangle( "fill", -self.w/2, -self.h/2, self.w, self.h )
    if self.debugText ~= nil then
        love.graphics.printf( self.debugText, -self.w/2, -self.h, self.w, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
    end

    love.graphics.pop()
end

function Laser:update( dt, i )
    self.pos:add( self.vel:multiplyCopy( MAX_LASER_VEL * dt ) )

    if self.vel:lengthsq() > 0 then
        for j, o in ipairs( lasers ) do
            -- All lasers that are still enabled except 'l'
            if i ~= j and o.vel:lengthsq() > 0 then

                local distVector = o.pos:subtractCopy( self.pos )
                local dist = distVector:length()
                -- This collision detection is very sloppy, but it's good enough for now
                -- TODO: Make this more accurate
                if dist < self.w/2 or dist < self.h/2 then
                    table.remove( lasers, i )
                    -- adjust index for order of removal
                    if i < j then j = j - 1 end
                    table.remove( lasers, j )

                    -- TODO: spawn enemy/powerup
                    return
                end
            end
        end

        -- Wall collisions
        if self.pos.x < 0 then
            self.vel:reflect( Vector:new( 1, 0 ) )
            self.pos.x = math.max( self.pos.x, 0 )
        elseif self.pos.x > W then
            self.vel:reflect( Vector:new( -1, 0 ) )
            self.pos.x = math.min( self.pos.x, W )
        elseif self.pos.y < 0 then
            self.vel:reflect( Vector:new( 0, 1 ) )
            self.pos.y = math.max( self.pos.y, 0 )
        elseif self.pos.y > H then
            self.vel:reflect( Vector:new( 0, -1 ) )
            self.pos.y = math.min( self.pos.y, H )
        end
        self.dir = self.vel:normalized()
    end
end
