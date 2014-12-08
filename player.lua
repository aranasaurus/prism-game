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
    p.color = { 255, 0, 0 }
    p.laserColors = {
        { 255, 112, 112 },
        { 255, 255, 64 },
        { 96, 96, 255 }
    }
    p.w = 48
    p.h = 32
    p.joystick = joystick

    return p
end

function Player:draw()
    love.graphics.push()
    love.graphics.translate( self.pos.x, self.pos.y )
    love.graphics.rotate( self.dir:angle() )

    love.graphics.setColor( 255, 0, 0 )
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
        end

        self.vel = leftInput:multiply( MAX_PLAYER_VEL * dt )
        self.dir = rightInput

        self.pos = self.pos:add( self.vel )
    end

    local sz = math.max( self.w, self.h )/2 + 4
    self.pos.x = math.min( self.pos.x, W - sz )
    self.pos.x = math.max( self.pos.x, sz )
    self.pos.y = math.min( self.pos.y, H - sz )
    self.pos.y = math.max( self.pos.y, sz )
end

function Player:fire()
    table.insert( lasers, Laser:new( self.pos, self.dir, self.laserColors[math.random( #self.laserColors )] ) )
end
