require "vector"
require "player"
require "laser"

DEAD_ZONE = 0.15
MAX_PLAYER_VEL = 800
LASER_VEL = MAX_PLAYER_VEL * 1.33

local p1 = {}
lasers = {}
effects = {}
enemies = {}
buffs = {}

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
function reset()
    createPlayer()
    lasers = {}
end

function createPlayer()
    local sticks = love.joystick.getJoysticks()

    p1 = Player:new( W/2, H/2, sticks[1] )
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
-- Effects --
-------------

function drawEffects()
    for _, e in pairs( effects ) do
        e:draw()
    end
end

function updateEffects( dt )
    local removables = {}
    for i, e in ipairs( effects ) do
        e:update( dt )
        if e.alpha <= 0 then
            removables[#removables + 1] = i
        end
    end

    for i = #removables, 1, -1 do
        table.remove( effects, i )
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
    p1:update( dt )
    updateLasers( dt )
    updateEffects( dt )
end

function love.draw()
    drawLasers()
    drawEffects()
    drawEnemies()
    drawBuffs()

    p1:draw()
    drawStats()
end

--------------
-- Controls --
--------------
function love.joystickadded( joystick )
    if p1.joystick == nil or not p1.joystick:isConnected() then
        p1.joystick = joystick
    end
end

function love.joystickremoved( joystick )
    if joystick == p1.joystick then
        p1.joystick = nil
    end
end

function love.joystickpressed( joystick, button )
    if joystick ~= p1.joystick then
        return
    end

    p1:fire()
end

-----------
-- Utils --
-----------

function combineColors( c1, c2 )
    local c = {}
    c[1] = math.min( c1[1] + c2[1], 255 )
    c[2] = math.min( c1[2] + c2[2], 255 )
    c[3] = math.min( c1[3] + c2[3], 255 )
    return c
end
