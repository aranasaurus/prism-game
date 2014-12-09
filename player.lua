require "vector"
require "laser"

Player = {}

function Player:new( x, y, joystick, maxHP )
    local p = {}
    setmetatable( p, self )
    self.__index = self

    p.pos = Vector:new( x, y )
    p.vel = Vector:new( 0, 0 )
    p.dir = Vector:new( 1, 0 )
    p.color = { 255, 80, 80, 255 }
    p.laserColors = {
        { 255, 128, 101 },
        { 248, 255, 64 },
        { 0, 96, 255 },
        { 65, 255, 96 }
    }
    p.w = 32
    p.h = math.floor( p.w * 9/16 )
    p.joystick = joystick
    p.fireRate = 0.1 -- seconds
    p.lastFired = 0
    p.maxHP = maxHP or 4
    p.hp = p.maxHP
    p.score = 0

    return p
end

function Player:draw()
    love.graphics.push()
    love.graphics.translate( self.pos.x, self.pos.y )
    love.graphics.rotate( self.dir:angle() )

    local a = 255
    if self.dead then
        a = self.alpha
    end
    love.graphics.setColor( self.color[1], self.color[2], self.color[3], a )
    love.graphics.setLineWidth( 3 )
    love.graphics.polygon( "line", -self.w/2, -self.h/2, self.w/2, 0, -self.w/2, self.h/2 )
    love.graphics.setColor( 255, 255, 255, 255 - (255 * (self.hp/self.maxHP)) )
    love.graphics.polygon( "fill", -self.w/2, -self.h/2, self.w/2, 0, -self.w/2, self.h/2 )
    if self.debugText ~= nil then
        love.graphics.setColor( 255, 255, 255 )
        love.graphics.printf( self.debugText, -self.w/2, -self.h*2, self.w * 8, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
    end
    love.graphics.pop()
end

function Player:update( dt )
    if self.dead then 
        self:explode()
        self.alpha = self.alpha - 3

        if self.alpha <= 0 then
            reset()
        end
        return
    end

    local lf = nil
    if self.joystick ~= nil then
        local leftInput = Vector:new( self.joystick:getGamepadAxis( "leftx" ), self.joystick:getGamepadAxis( "lefty" ) )
        local rightInput = Vector:new( self.joystick:getGamepadAxis( "rightx" ), self.joystick:getGamepadAxis( "righty" ) )

        if leftInput:length() < DEAD_ZONE then
            leftInput.x = 0
            leftInput.y = 0
        end

        self.pos = self.pos:add( self.vel )

        if rightInput:length() < DEAD_ZONE then
            rightInput = self.dir
        else
            lf = self:fire()
        end

        self.vel = leftInput:multiply( MAX_PLAYER_VEL * dt )
        self.dir = rightInput:normalize()

    else
        -- TODO: keyboard controls
    end

    -- Keep it on screen
    local sz = math.max( self.w, self.h )/2 + 4
    self.pos.x = math.min( self.pos.x, W - sz )
    self.pos.x = math.max( self.pos.x, sz )
    self.pos.y = math.min( self.pos.y, H - sz )
    self.pos.y = math.max( self.pos.y, sz )

    for i, l in ipairs( lasers ) do
        if l ~= lf and self:collidingWithLaser( l ) then
            self.hp = self.hp - 1
            l:die( true, l.color )

            if self.hp <= 0 then
                self:die()
            end
        end
    end
end

function Player:die()
    if self.dead then return end
    self.alpha = 255
    self.dead = true
    self.diedAt = love.timer.getTime()
    self:explode()
    lasers = {}
end

function Player:explode()
    if self.lastExplosion ~= nil and love.timer.getTime() - self.lastExplosion < 0.05 then return end

    local density = 8 * ((love.timer.getTime() - self.diedAt) * 1.1 )
    local dec = 8
    for i = 1, density do
        local c = self.laserColors[love.math.random( 1, #self.laserColors )]
        local len = love.math.random( 4, 16 )
        local dens = love.math.random( 6, 32 )
        effects[#effects + 1] = Spark:new( self.pos, randomDir( self.dir ), c, dec, len, dens )
    end
    self.lastExplosion = love.timer.getTime()
end

function Player:fire()
    if self:canFire() then
        local l = Laser:new( self.pos:add( self.dir:multiply( math.ceil( self.w * 0.8 ) ) ), self.dir, self.laserColors[math.random( #self.laserColors )], self )
        table.insert( lasers, l )
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

function Player:bbox()
    local horizontal = self.dir:multiply( self.w/2 )
    local vertical = self.dir:turnLeft():multiply( self.h/2 )
    local top = self.pos:subtract( vertical )
    local bot = self.pos:add( vertical )

    return {
        top:subtract( horizontal ),
        top:add( horizontal ),
        bot:add( horizontal ),
        bot:subtract( horizontal )
    }
end
