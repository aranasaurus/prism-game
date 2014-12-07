require "vector"
require "player"

DEAD_ZONE = 0.15
MAX_PLAYER_VEL = 800
MAX_LASER_VEL = MAX_PLAYER_VEL * 1.33

-----------------
-- Debug Stats --
-----------------
DEBUG = true
local t = 0
local lastUpdate = 0
local updateInterval = 0.25
local statsFmt = "FPS: %d\n MEM: %.1fKB"
local memCount = collectgarbage( "count" )

function drawStats()
    if DEBUG then
        if t - lastUpdate > updateInterval then
            lastUpdate = t
            memCount = collectgarbage( "count" )
        end

        local stats = string.format(statsFmt, love.timer.getFPS(), memCount )

        love.graphics.push()
        love.graphics.origin()
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.printf( stats, 10, 10, W - 20, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
        love.graphics.pop()
    end
end

----------------
-- Game Logic --
----------------
lasers = {}
enemies = {}
buffs = {}

function reset()
    createPlayer()
    lasers = {}
end

------------
-- Lasers --
------------
function fireLaser( src )
    local l = {
        pos = Vector:new( src.pos.x, src.pos.y ),
        vel = src.facing:normalized(),
        w = 24,
        h = 4
    }

    table.insert( lasers, l )
end

function drawLasers()
    for _, l in pairs( lasers ) do
        love.graphics.push()
        love.graphics.translate( l.pos.x, l.pos.y )
        love.graphics.rotate( l.vel:angle() )

        love.graphics.setColor( 64, 255, 64 )
        love.graphics.rectangle( "fill", -l.w/2, -l.h/2, l.w, l.h )
        if l.debugText ~= nil then
            love.graphics.printf( l.debugText, -l.w/2, -l.h, l.w, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
        end

        love.graphics.pop()
    end
end

function updateLasers( dt )
    for _, l in pairs( lasers ) do
        l.pos:add( l.vel:multiplyCopy( MAX_LASER_VEL * dt ) )

        -- Wall collisions
        if l.pos.x < 0 then
            l.vel:reflect( Vector:new( 1, 0 ) )
            l.pos.x = math.max( l.pos.x, 0 )
        elseif l.pos.x > W then
            l.vel:reflect( Vector:new( -1, 0 ) )
            l.pos.x = math.min( l.pos.x, W )
        elseif l.pos.y < 0 then
            l.vel:reflect( Vector:new( 0, 1 ) )
            l.pos.y = math.max( l.pos.y, l.h )
        elseif l.pos.y > H then
            l.vel:reflect( Vector:new( 0, -1 ) )
            l.pos.y = math.min( l.pos.y, H )
        end
    end
end

-------------
-- Enemies --
-------------
function drawEnemies()
end

-----------
-- Buffs --
-----------
function drawBuffs()
end

----------
-- Löve --
----------
function love.load( arg ) 
    W, H = love.window.getDimensions()
    reset()
end

function love.update( dt )
    t = t + dt
    updatePlayer( dt )
    updateLasers( dt )
end

function love.draw()
    drawPlayer()
    drawLasers()
    drawEnemies()
    drawBuffs()
    drawStats()
end

--------------
-- Controls --
--------------
function love.joystickadded( joystick )
    if player.joystick == nil or not player.joystick:isConnected() then
        player.joystick = joystick
    end
end

function love.joystickremoved( joystick )
    if joystick == player.joystick then
        player.joystick = nil
    end
end

function love.joystickpressed( joystick, button )
    if joystick ~= player.joystick then
        return
    end

    fireLaser( player )
end

