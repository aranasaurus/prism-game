require "vector"
require "effects"
require "color"

Laser = {}

function Laser:new( pos, dir, player )
    local l = {}
    setmetatable( l, self )
    self.__index = self

    l.pos = pos:copy()
    l.dir = dir:normalize()
    if player.shields > 0 then
        l.color = player.color:combine( player.shieldColor )
    else
        l.color = player.color:copy()
    end
    l.w = 24
    l.h = 4
    l.player = player

    l:loadSprite()

    return l
end

function Laser:loadSprite()
    if not Laser.sprite then
        Laser.sprite = love.graphics.newCanvas( self.w, self.h )

        love.graphics.push()
        love.graphics.origin()
        love.graphics.setCanvas( Laser.sprite )
        love.graphics.setColor( 1, 1, 1 )
        love.graphics.setLineWidth( self.h * love.window.getDPIScale() )
        love.graphics.rectangle( "fill", 0, 0, self.w, self.h )
        love.graphics.setCanvas()
        love.graphics.pop()
    end
end

function Laser:draw()
    love.graphics.push()
    love.graphics.origin()

    love.graphics.setColor( self.color:toarray() )
    love.graphics.draw( self.sprite, self.pos.x, self.pos.y, self.dir:angle() )

    if self.debugText ~= nil then
        love.graphics.setColor( 1, 1, 1 )
        love.graphics.printf( self.debugText, -self.w/2, -self.h*4, self.w, "left", 0, love.window.getDPIScale(), love.window.getDPIScale() )
    end

    love.graphics.pop()
end

function Laser:die( withEffects, color )
    -- remove this laser from the lasers array
    for i, l in ipairs( lasers ) do
        if l == self then
            removeAndReplace( lasers, i, nil, "lasers" )
            break
        end
    end

    if withEffects then
        effects[#effects + 1] = Spark:new( self.pos, self.dir, self.color:combine( color ) )
        -- TODO: Sound effects?
    end

    -- TODO: spawn enemy/powerup
end

function Laser:update( dt, i )
    self.pos = self.pos + (self.dir * LASER_VEL * dt)

    for j, o in ipairs( lasers ) do
        -- All lasers except this one
        if i ~= j then
            if self:colliding( o ) then
                if self.color.name ~= o.color.name then
                    local s1 = self:getDamage( o.color )
                    local s2 = o:getDamage( self.color )
                    self.player:addScore( s1 )
                    o.player:addScore( s2 )
                    effects[ #effects+1 ] = FloatingText:new( "+".. s1 + s2, self.color:combine( o.color ), self.pos ) --, self.player.pos )
                end
                self:die( true, o.color )
                o:die()
                return
            end
        end
    end

    -- Wall collisions
    if self.pos.x < 0 then
        self.dir = self.dir:reflect( vector( 1, 0 ) )
        self.pos.x = math.max( self.pos.x, 0 )
    elseif self.pos.x > W then
        self.dir = self.dir:reflect( vector( -1, 0 ) )
        self.pos.x = math.min( self.pos.x, W )
    elseif self.pos.y < 0 then
        self.dir = self.dir:reflect( vector( 0, 1 ) )
        self.pos.y = math.max( self.pos.y, 0 )
    elseif self.pos.y > H then
        self.dir = self.dir:reflect( vector( 0, -1 ) )
        self.pos.y = math.min( self.pos.y, H )
    end
end

function Laser:colliding( o )
    -- This collision detection is very sloppy, but it's good enough for now
    -- TODO: Make this more accurate
    return (o.pos - self.pos):length() < self.w/2
end

function Laser:lineSegment()
    local hl = self.dir * (self.w/2)
    return { self.pos - hl, self.pos + hl }
end

function Laser:getDamage( c )
    if self.color.name == "orange" then
        if c.name == "red" or c.name == "yellow" then
            return 1
        else
            return 2
        end
    elseif self.color.name == "purple" then
        if c.name == "red" or c.name == "blue" then
            return 1
        else
            return 2
        end
    elseif self.color.name == "green" then
        if c.name == "yellow" or c.name == "blue" then
            return 1
        else
            return 2
        end
    elseif self.color.name == "red" then
        if c.name == "orange" or c.name == "purple" then
            return 1
        else
            return 2
        end
    elseif self.color.name == "blue" then
        if c.name == "purple" or c.name == "green" then
            return 1
        else
            return 2
        end
    elseif self.color.name == "yellow" then
        if c.name == "green" or c.name == "orange" then
            return 1
        else
            return 2
        end
    end

    return 2
end

