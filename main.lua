require "vector"
require "player"
require "laser"

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

function drawLasers()
    for _, l in pairs( lasers ) do
        l:draw()
    end
end

function updateLasers( dt )
    for i, l in ipairs( lasers ) do
        l:update( dt, i )
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
    drawLasers()
    drawEnemies()
    drawBuffs()
    drawPlayer()
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

    fireLaser()
end

