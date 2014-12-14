require "vector"
require "player"
require "laser"

DEAD_ZONE = 0.2
MAX_PLAYER_VEL = 800
LASER_VEL = MAX_PLAYER_VEL * 1.33

local canvases = {}
local bg = {}
local bg_sx = 1
local bg_sy = 1
local bg_index = 1
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
        love.graphics.printf( stats, 10, 10, W - 120, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
        love.graphics.printf( "SCORE: "..string.gsub( tostring(p1.score), "^(-?%d+)(%d%d%d)", '%1,%2' ), W/2, 10, W/2 - 10, "right", 0, love.window.getPixelScale(), love.window.getPixelScale() )
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

    p1 = Player:new( W/2, H/2, sticks[1], p1.colorIndex, p1.shieldColorIndex )
end

-------------
-- Players --
-------------

function renderPlayers( canvas )
    love.graphics.setCanvas( canvas )
    p1:draw()
    love.graphics.setCanvas()
end

------------
-- Lasers --
------------

function renderLasers( canvas )
    love.graphics.setCanvas( canvas )
    for _, l in pairs( lasers ) do
        l:draw()
    end
    love.graphics.setCanvas()
end

function updateLasers( dt )
    for i, l in ipairs( lasers ) do
        l:update( dt, i )
    end
end

-------------
-- Effects --
-------------

function renderEffects( canvas )
    love.graphics.setCanvas( canvas )
    for _, e in pairs( effects ) do
        e:draw()
    end
    love.graphics.setCanvas()
end

function updateEffects( dt )
    local removables = {}
    for i, e in ipairs( effects ) do
        e:update( dt )
        if e.color.a <= 0 then
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
function renderEnemies( canvas )
    love.graphics.setCanvas( canvas )
    love.graphics.setCanvas()
end

-----------
-- Buffs --
-----------
function renderBuffs( canvas )
    love.graphics.setCanvas( canvas )
    love.graphics.setCanvas()
end

----------
-- Löve --
----------
function love.load( arg ) 
    W, H = love.window.getDimensions()
    canvases = {
        effects = love.graphics.newCanvas(),
        entities = love.graphics.newCanvas(),
        glow = love.graphics.newCanvas()
    }
    loadBG( bg_index )
    reset()
end

function love.update( dt )
    t = t + dt
    p1:update( dt )
    updateLasers( dt )
    updateEffects( dt )
end

function love.draw()
    canvases.effects:clear()
    canvases.entities:clear()
    canvases.glow:clear()

    renderLasers( canvases.effects )
    renderEffects( canvases.effects )
    renderEnemies( canvases.entities )
    renderBuffs( canvases.entities )
    renderPlayers( canvases.entities )

    -- reset stuff to defaults
    love.graphics.setCanvas()
    love.graphics.setBlendMode( "alpha" )
    love.graphics.setShader()
    love.graphics.setColor( 255, 255, 255 )

    drawBG()

    love.graphics.draw( canvases.entities, 0, 0 )
    love.graphics.draw( canvases.effects, 0, 0 )
    love.graphics.draw( canvases.glow, 0, 0 )

    drawStats()

    --[[ Color tests
    love.graphics.setColor( Color.colors.red:toarray() )
    love.graphics.rectangle( "fill", 100, 100, 100, 100 )
    love.graphics.setColor( Color.colors.yellow:toarray() )
    love.graphics.rectangle( "fill", 210, 100, 100, 100 )
    love.graphics.setColor( Color.colors.blue:toarray() )
    love.graphics.rectangle( "fill", 320, 100, 100, 100 )
    love.graphics.setColor( Color.colors.orange:toarray() )
    love.graphics.rectangle( "fill", 100, 210, 100, 100 )
    love.graphics.setColor( Color.colors.purple:toarray() )
    love.graphics.rectangle( "fill", 210, 210, 100, 100 )
    love.graphics.setColor( Color.colors.green:toarray() )
    love.graphics.rectangle( "fill", 320, 210, 100, 100 )
    --]]

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

function love.keypressed( key )
    if key == "q" then
        p1:nextColor()
    end

    if key == "e" then
        p1:nextShieldColor()
    end
end

function love.gamepadpressed( joystick, button )
    if joystick ~= p1.joystick then
        return
    end

    if button == "dpup" or button == "dpright" then
        nextBG()
    elseif button == "dpdown" or button == "dpleft" then
        prevBG()
    end

    if button == "back" then
        reset()
    end

    if button == "leftshoulder" then
        p1:nextColor()
    end
    if button == "rightshoulder" then
        p1:nextShieldColor()
    end

end

-------
-- BG -
-------

function nextBG()
    bg_index = bg_index + 1
    if bg_index > 5 then
        bg_index = 1
    end
    loadBG()
end

function prevBG()
    bg_index = bg_index - 1
    if bg_index < 1 then
        bg_index = 5
    end
    loadBG()
end

function loadBG()
    bg = love.graphics.newImage( "res/bg"..bg_index..".png" )
    bg_sx = W / bg:getWidth()
    bg_sy = H / bg:getHeight()
end

function drawBG()
    love.graphics.draw( bg, 0, 0, 0, bg_sx, bg_sy )
    love.graphics.setColor( 0, 0, 0, 255 * 0.58 )
    love.graphics.rectangle( "fill", 0, 0, W, H )
    love.graphics.setColor( 255, 255, 255 )
end
