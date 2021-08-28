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

    p.pos = vector( x, y )
    p.vel = vector( 0, 0 )
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
    else
        p:changeColor( color or love.math.random( 1, #Player.colors ) )
    end
    p.shieldColorIndex = shieldColorIndex or love.math.random( 1, #Player.colors )
    p:changeShieldColor( p.shieldColorIndex )

    p.death = {
        diedAt = 0,
        duration = 0,
        max_duration = 1.33,
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
    end

    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate( self.pos.x, self.pos.y )
    love.graphics.rotate( self.rot )
    love.graphics.setColor( self.color:toarray() )
    love.graphics.draw( self.sprite, -self.w/2, -self.h/2 )

    if self.debugText ~= nil then
        love.graphics.setColor( 255, 255, 255 )
        love.graphics.printf( self.debugText, -self.w/2, -self.h*2, self.w * 8, "left", 0, love.window.getDPIScale(), love.window.getDPIScale() )
    end
    love.graphics.pop()
end

function Player:drawShield()
    love.graphics.push()
    love.graphics.origin()
    local c1 = self.shieldColor:copy()
    local c2 = self.shieldColor:copy()
    local shieldLevel = self.shields / self.maxShields

    -- outer
    c1.a = math.max( 0, math.min( 255, c1.a * shieldLevel * 3 ) )
    love.graphics.setColor( c1:toarray() )
    love.graphics.setLineWidth( 2 )
    love.graphics.circle( "line", self.pos.x, self.pos.y, self.w/1.6 )

    -- inner
    c2.a = math.max( 0, math.min( 26, (c2.a / 8) * shieldLevel ) )
    love.graphics.setColor( c2:toarray() )
    love.graphics.circle( "fill", self.pos.x, self.pos.y, self.w/1.6 )
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
    self.pos = self.pos + (self.vel * MAX_PLAYER_VEL * dt)

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
            self:takeDamage( l )
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

    local density = 8 * math.asin(self.death.duration)
    local availableColors = {}
    for k, v in pairs( Color.colors ) do
        availableColors[ #availableColors+1 ] = k
    end
    for i = 1, density do
        local c = Color.colors[ availableColors[ love.math.random( 1, #availableColors ) ] ]
        local len = love.math.random( 4, 12 )
        local dens = love.math.random( 8, 28 )
        local dec = love.math.random( 1, 2 ) * love.math.random() * 0.5
        local dur = 0.33
        effects[#effects + 1] = Spark:new( self.pos, randomDir( vector( 1, 0 ):rotate( self.rot ) ), c, dec, len, dens, dur )
    end
    self.lastExplosion = love.timer.getTime()
end

function Player:fire()
    if self:canFire() then
        local dir = vector( self.w * 0.85, 0 ):rotate( self.rot )
        local l = Laser:new( self.pos + dir, dir, self )
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

    if (self.pos - ls[1]):length() <= self.h then
        return true
    end

    if (self.pos - laser.pos):length() <= self.h then
        return true
    end

    if (self.pos - ls[2]):length() <= self.h then
        return true
    end

    return false
end

function Player:addScore( s )
    self.score = self.score + s
end

function Player:takeDamage( src )
    local dmg = 0
    local effectColor = src.color:combine( self.shieldColor )
    if self.shields > 0 then
        -- take shield damage
        if src.color.name ~= self.shieldColor.name then
            dmg = src:getDamage( self.shieldColor )
            self.shields = self.shields - dmg
        end
    else
        -- take hp damage
        effectColor = src.color:combine( self.color )
        if src.color.name ~= self.color.name then
            dmg = src:getDamage( self.color )
            self.hp = self.hp - dmg
        end
    end

    src:die( true, effectColor )
    if dmg > 0 then
        self:addScore( dmg )
        effects[ #effects+1 ] = FloatingText:new( string.format( "+%d", dmg ), effectColor, src.pos )
    end
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

