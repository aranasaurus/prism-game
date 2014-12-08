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

    if self.sparks then
        for i, s in ipairs( self.sparks ) do
            love.graphics.push()
            love.graphics.rotate( s.vel:angle() )
            love.graphics.translate( s.pos.x, s.pos.y )

            love.graphics.setColor( 168, 224, 128 )
            love.graphics.line( -self.w/4, 0, self.w/4, 0 )

            love.graphics.pop()
        end

        love.graphics.pop()
        return
    end

    love.graphics.rotate( self.dir:angle() )
    love.graphics.setColor( 64, 255, 64 )
    love.graphics.rectangle( "fill", -self.w/2, -self.h/2, self.w, self.h )
    if self.debugText ~= nil then
        love.graphics.printf( self.debugText, -self.w/2, -self.h, self.w, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
    end

    love.graphics.pop()
end

function Laser:die( withEffects )
    -- TODO: pretty effects

    -- remove this laser from the lasers array
    if not withEffects then
        for i, l in ipairs( lasers ) do
            if l == self then
                table.remove( lasers, i )
            end
        end
    end

    if not self.sparks and withEffects then
        table.insert( deadlasers, self )
        self.sparks = {}
        local num_sparks = 12
        local angle = (2 * math.pi) / num_sparks
        for i = 1, num_sparks do
            local s = {
                pos = Vector:new( 0, 0 ),
                vel = self.vel:rotate( angle * i )
            }

            table.insert( self.sparks, s )
        end
    end
end

function Laser:update( dt, i )
    if self.sparks then
        for j, s in ipairs( self.sparks ) do
            s.pos:add( self.vel:multiplyCopy( MAX_LASER_VEL * 1.66 * dt ) )
        end
        return
    end

    self.pos:add( self.vel:multiplyCopy( MAX_LASER_VEL * dt ) )

    if self.vel:lengthsq() > 0 then
        for j, o in ipairs( lasers ) do
            -- All lasers that are still enabled except 'l'
            if i ~= j and not o.sparks then

                local distVector = o.pos:subtractCopy( self.pos )
                local dist = distVector:length()
                -- This collision detection is very sloppy, but it's good enough for now
                -- TODO: Make this more accurate
                if dist < self.w/2 then
                    self:die( true )
                    o:die( false )

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
