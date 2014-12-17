require "vector"
require "laser"
require "color"
require "controllers"

Player = {
    colors = { "red", "yellow", "blue" }
}

function Player:new( x, y, joystick, color, shieldColorIndex, maxShields, maxHP )
    local p = {}
    setmetatable( p, self )
    self.__index = self

    p.pos = Vector:new( x, y )
    p.vel = Vector:new( 0, 0 )
    p.rot = 0
    p.w = 48
    p.h = math.floor( p.w * 9/16 )
    if joystick then
        p.controller = GamepadController:new( p, joystick )
    else
        p.controller = KeyboardController:new( p )
    end
    p.fireRate = 0.1 -- seconds
    p.lastFired = 0
    p.maxShields = maxShields or 8
    p.maxHP = maxHP or 1
    p.shields = p.maxShields
    p.hp = p.maxHP
    p.score = 0
    if type( color ) == "string" then
        for i, c in ipairs( Player.colors ) do
            if c == color then
                p:changeColor( i )
                break
            end
        end

        p.color = Color.colors[ color ]:copy()
    else
        p:changeColor( color or 1 )
    end
    p.shieldColorIndex = shieldColorIndex or 2
    p:changeShieldColor( p.shieldColorIndex )

    p.death = {
        diedAt = 0,
        duration = 0,
        max_duration = 1.6,
    }

    p:loadSprite()

    return p
end

function Player:loadSprite( image )
    if image then
        self.sprite = image
        return
    end

    self.sprite = love.graphics.newCanvas( self.w, self.h )
    love.graphics.push()
    love.graphics.setCanvas( self.sprite )
    
    local back = 0
    local front = self.w - 4
    local top = self.h/4
    local bottom = self.h - self.h/4
    love.graphics.polygon( "fill", back, top, front, self.h/2, back, bottom )

    love.graphics.setCanvas()
    love.graphics.pop()
end

function Player:draw()
    if self.dead then
        return
    else
        love.graphics.push()
        love.graphics.translate( self.pos.x, self.pos.y )
        love.graphics.setColor( self.shieldColor:toarray() )
        love.graphics.setLineWidth( 2 )
        local c = self.shieldColor:copy()
        c.a = math.max(c.a * (self.shields/self.maxShields)/1.8, 0)
        love.graphics.setColor( c:toarray() )
        love.graphics.circle( "fill", 0, 0, math.max(self.w, self.h)/2 + 4 )
        love.graphics.pop()
    end

    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate( self.pos.x, self.pos.y )
    love.graphics.rotate( self.rot )
    love.graphics.setColor( self.color:toarray() )
    love.graphics.draw( self.sprite, -self.w/2, -self.h/2 )

    if self.debugText ~= nil then
        love.graphics.setColor( 255, 255, 255 )
        love.graphics.printf( self.debugText, -self.w/2, -self.h*2, self.w * 8, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
    end
    love.graphics.pop()
end

function Player:update( dt )
    if self.dead then 
        self:explode()
        self.death.duration = love.timer.getTime() - self.death.diedAt

        if self.death.duration > self.death.max_duration then
            reset()
        end
        return
    end

    -- Gather inputs
    self.rot = self.controller:getRotation( dt )
    self.vel = self.controller:getVelocity()
    self.pos = self.pos:add( self.vel:multiply( MAX_PLAYER_VEL * dt ) )

    -- Keep it on screen
    local sz = math.max( self.w, self.h )/2 + 4
    self.pos.x = math.min( self.pos.x, W - sz )
    self.pos.x = math.max( self.pos.x, sz )
    self.pos.y = math.min( self.pos.y, H - sz )
    self.pos.y = math.max( self.pos.y, sz )

    local firedLaser = {}
    if self.controller:isFiring() then
        firedLaser = self:fire()
    end
    for i, l in ipairs( lasers ) do
        if l ~= firedLaser and self:collidingWithLaser( l ) then
            if self.shields > 0 then
                -- take shield damage
                if l.color.name ~= self.shieldColor.name then
                    self.shields = self.shields - l:getDamage( self.shieldColor )
                    l:die( true, l.color:combine( self.shieldColor ) )

                    if self.shields < 1 and self.shieldColorIndex ~= self.colorIndex then
                        self:changeShieldColor( self.colorIndex )
                    end
                end
            else
                -- take hp damage
                if l.color.name ~= self.color.name then
                    self.hp = self.hp - l:getDamage( self.color )
                    l:die( true, l.color:combine( self.color ) )
                end
            end
        end

        if self.hp <= 0 then
            self:die()
        end
    end
end

function Player:die()
    if self.dead then return end
    self.dead = true
    self.death.diedAt = love.timer.getTime()
    self.death.duration = 0
    self:explode()
    lasers = {}
end

function Player:explode()
    if self.lastExplosion ~= nil and love.timer.getTime() - self.lastExplosion < 0.05 then return end

    local density = 8 * (self.death.duration * 1.1)
    local dec = 8
    local availableColors = {}
    for k, v in pairs( Color.colors ) do
        availableColors[ #availableColors+1 ] = k
    end
    for i = 1, density do
        local c = Color.colors[ availableColors[ love.math.random( 1, #availableColors ) ] ]
        local len = love.math.random( 4, 12 )
        local dens = love.math.random( 8, 28 )
        effects[#effects + 1] = Spark:new( self.pos, randomDir( Vector:new( 1, 0 ):rotate( self.rot ) ), c, dec, len, dens )
    end
    self.lastExplosion = love.timer.getTime()
end

function Player:fire()
    if self:canFire() then
        local dir = Vector:new( self.w * 0.85, 0 ):rotate( self.rot )
        local l = Laser:new( self.pos:add( dir ), dir, self )
        lasers[ #lasers + 1 ] = l
        self.lastFired = love.timer.getTime()
        return l
    end
end

function Player:canFire()
    if self.dead then return false end

    local t = love.timer.getTime()
    local dly = t - self.lastFired
    return dly > self.fireRate
end

function Player:collidingWithLaser( laser )
    local ls = laser:lineSegment()

    if self.pos:subtract( ls[1] ):length() <= self.h then
        return true
    end

    if self.pos:subtract( laser.pos ):length() <= self.h then
        return true
    end

    if self.pos:subtract( ls[2] ):length() <= self.h then
        return true
    end

    return false
end

function Player:addScore( s )
    self.score = self.score + s
end

function Player:changeColor( index )
    self.colorIndex = index
    self.color = Color.colors[ Player.colors[index] ]:copy()
end

function Player:nextColor()
    local i = self.colorIndex + 1
    if i > #Player.colors then
        i = 1
    end
    self:changeColor( i )
    if self.shields < 1 then
        self:changeShieldColor( i )
    end
end

function Player:changeShieldColor( index )
    self.shieldColorIndex = index
    self.shieldColor = Color.colors[Player.colors[index]]:copy()
end

function Player:nextShieldColor()
    local i = self.shieldColorIndex + 1
    if i > #Player.colors then
        i = 1
    end
    self:changeShieldColor( i )
    if self.shields < 1 then
        self:changeColor( i )
    end
end

