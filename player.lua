require "vector"
require "laser"

Player = {}

function Player:new( x, y, joystick )
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
        { 0, 96, 255 }
    }
    p.w = 28
    p.h = math.floor( p.w * 9/16 )
    p.joystick = joystick
    p.fireRate = 0.1 -- seconds
    p.lastFired = 0

    return p
end

function Player:draw()
    love.graphics.push()
    love.graphics.translate( self.pos.x, self.pos.y )
    love.graphics.rotate( self.dir:angle() )

    love.graphics.setColor( 255, 255, 255 )
    love.graphics.setLineWidth( 3 )
    love.graphics.polygon( "line", -self.w/2, -self.h/2, self.w/2, 0, -self.w/2, self.h/2 )
    love.graphics.setColor( self.color )
    love.graphics.polygon( "fill", -self.w/2, -self.h/2, self.w/2, 0, -self.w/2, self.h/2 )
    if self.debugText ~= nil then
        love.graphics.setColor( 255, 255, 255 )
        love.graphics.printf( self.debugText, -self.w/2, -self.h, self.w * 2, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
    end
    love.graphics.pop()
end

function Player:update( dt )
    if self.joystick ~= nil then
        local leftInput = Vector:new( self.joystick:getGamepadAxis( "leftx" ), self.joystick:getGamepadAxis( "lefty" ) )
        local rightInput = Vector:new( self.joystick:getGamepadAxis( "rightx" ), self.joystick:getGamepadAxis( "righty" ) )

        if leftInput:length() < DEAD_ZONE then
            leftInput.x = 0
            leftInput.y = 0
        end
        if rightInput:length() < DEAD_ZONE then
            rightInput = self.dir
        else
            self:fire()
        end

        self.vel = leftInput:multiply( MAX_PLAYER_VEL * dt )
        self.dir = rightInput

        self.pos = self.pos:add( self.vel )
    else
        -- TODO: keyboard controls
    end

    local sz = math.max( self.w, self.h )/2 + 4
    self.pos.x = math.min( self.pos.x, W - sz )
    self.pos.x = math.max( self.pos.x, sz )
    self.pos.y = math.min( self.pos.y, H - sz )
    self.pos.y = math.max( self.pos.y, sz )
end

function Player:fire()
    if self:canFire() then
        table.insert( lasers, Laser:new( self.pos, self.dir, self.laserColors[math.random( #self.laserColors )] ) )
        self.lastFired = love.timer.getTime()
    end
end

function Player:canFire()
    local t = love.timer.getTime()
    local dly = t - self.lastFired
    return dly > self.fireRate
end
