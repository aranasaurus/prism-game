require "util"
require "vector"
require "player"
require "laser"
require "bloom"

DEAD_ZONE = 0.2
MAX_PLAYER_VEL = 800
LASER_VEL = MAX_PLAYER_VEL * 1.33

local colorTestRender = false
local canvases = {}
local bg = {}
local bg_sx = 1
local bg_sy = 1
local bg_index = 1
local p1 = {}
LASERS = {}
EFFECTS = {}
ENEMIES = {}
BUFFS = {}
PAUSED = false

-----------------
-- Debug Stats --
-----------------
DEBUG = true
local t = 0
local lastUpdate = 0
local updateInterval = 0.25
local statsFmt = "FPS: %d\n RT: %.3fms (%.3fms)\n MEM: %.1fKB (%.1fKB)"
local memCounts = {collectgarbage( "count" )}
local memIndex = 1
local memCountsSize = 20
local maxMem = 0
local delta = 0
local laserDebug = false
local shieldDebug = false
local laserBloom = {}
local shieldBloom = {}

local function drawStats()
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor( 1, 1, 1, 1 )
    love.graphics.printf( "SCORE: "..string.gsub( tostring(p1.score), "^(-?%d+)(%d%d%d)", '%1,%2' ), W/2, 10, W/2 - 10, "right", 0, love.window.getDPIScale(), love.window.getDPIScale() )

    if DEBUG then
        if t - lastUpdate > updateInterval then
            lastUpdate = t

            memIndex = memIndex + 1
            if memIndex > memCountsSize then
                memIndex = 1
            end
            memCounts[memIndex] = collectgarbage( "count" )
            maxMem = 0
            for i, v in ipairs(memCounts) do
                maxMem = math.max( v, maxMem )
            end
            delta = love.timer.getDelta()*1000
        end

        local stats = string.format(statsFmt, love.timer.getFPS(), delta, love.timer.getAverageDelta()*1000, memCounts[memIndex], maxMem )

        love.graphics.printf( stats, 10, 10, W - 120, "left", 0, love.window.getDPIScale(), love.window.getDPIScale() )
    end

    love.graphics.pop()
end

----------------
-- Game Logic --
----------------

local function createPlayer()
    local sticks = love.joystick.getJoysticks()

    p1 = Player:new( W/2, H/2, sticks[1], p1.colorIndex )
end

function RESET()
    createPlayer()
    LASERS = {}
end

-------------
-- Players --
-------------

local function drawPlayers()
    p1:draw()
end

------------
-- Lasers --
------------

local function drawLasers()
    for _, l in pairs( LASERS ) do
        l:draw()
    end
end

local function updateLasers( dt )
    for i, l in ipairs( LASERS ) do
        l:update( dt, i )
    end
end

-------------
-- Effects --
-------------

local function drawEffects()
    for _, e in pairs( EFFECTS ) do
        e:draw()
    end
end

local function updateEffects( dt )
    local i = 1
    local sz = #EFFECTS
    while i <= sz do
        local e = EFFECTS[i]
        e:update( dt )
        if love.timer.getTime() - e.t > e.duration then
            Utils.removeAndReplace( EFFECTS, i, sz )
            -- update the size
            sz = sz - 1
            -- next iteration will have the same i value and analyze the newly moved effect
        else
            -- keep this effect in the list, advance to the next.
            i = i + 1
        end
    end
end

-------------
-- Enemies --
-------------

local function drawEnemies()
end

-----------
-- Buffs --
-----------

local function drawBuffs()
end

-------
-- BG -
-------

local function loadBG()
    bg = love.graphics.newImage( "res/bg"..bg_index..".png" )
    bg_sx = W / bg:getWidth()
    bg_sy = H / bg:getHeight()
end

local function nextBG()
    bg_index = bg_index + 1
    if bg_index > 5 then
        bg_index = 1
    end
    loadBG()
end

local function prevBG()
    bg_index = bg_index - 1
    if bg_index < 1 then
        bg_index = 5
    end
    loadBG()
end

local function drawBG()
    love.graphics.draw( bg, 0, 0, 0, bg_sx, bg_sy )
    love.graphics.setColor( 0, 0, 0, 0.58 )
    love.graphics.rectangle( "fill", 0, 0, W, H )
    love.graphics.setColor( 1, 1, 1 )
end

----------
-- Löve --
----------

function love.load( arg )
    W, H = love.graphics.getDimensions()
    canvases = {
        effects = love.graphics.newCanvas(),
        entities = love.graphics.newCanvas()
    }
    loadBG( bg_index )
    RESET()

    laserBloom = CreateBloomEffect( W/4, H/4 )
    laserBloom:setIntensity( 1, 2 )
    laserBloom:setSaturation( 1, 2 )
    laserBloom:setThreshold( 0.1 )

    shieldBloom = CreateBloomEffect( W, H )
    shieldBloom:setIntensity( 1, 2 )
    shieldBloom:setSaturation( 1, 1.33 )
    shieldBloom:setThreshold( 0.0 )

    love.graphics.setLineJoin( "miter" )
end

function love.update( dt )
    t = t + dt
    if PAUSED then return end
    p1:update( dt )
    updateLasers( dt )
    updateEffects( dt )
end

function love.draw()
    love.graphics.setCanvas(canvases.effects)
    love.graphics.clear()
    canvases.effects:renderTo( drawLasers )
    canvases.effects:renderTo( drawEffects )

    love.graphics.setCanvas(canvases.entities)
    love.graphics.clear()
    canvases.entities:renderTo( drawEnemies )
    canvases.entities:renderTo( drawBuffs )
    canvases.entities:renderTo( drawPlayers )

    local color_tests = function()
        if not colorTestRender then return end
        local w, h = 24, 4
        -- Color tests
        love.graphics.setColor( Color.colors.red:toarray() )
        love.graphics.rectangle( "fill", 100, 100, w, h )
        love.graphics.setColor( Color.colors.yellow:toarray() )
        love.graphics.rectangle( "fill", 250, 100, w, h )
        love.graphics.setColor( Color.colors.blue:toarray() )
        love.graphics.rectangle( "fill", 400, 100, w, h )
        love.graphics.setColor( Color.colors.orange:toarray() )
        love.graphics.rectangle( "fill", 100, 250, w, h )
        love.graphics.setColor( Color.colors.purple:toarray() )
        love.graphics.rectangle( "fill", 250, 250, w, h )
        love.graphics.setColor( Color.colors.green:toarray() )
        love.graphics.rectangle( "fill", 400, 250, w, h )
        love.graphics.setColor( 1, 1, 1 )
    end
    if colorTestRender then
        canvases.effects:renderTo( color_tests )
    end

    -- reset stuff to defaults
    love.graphics.setCanvas()
    love.graphics.setBlendMode( "alpha" )
    love.graphics.setShader()
    love.graphics.setColor( 1, 1, 1 )

    drawBG()
    drawStats()

    love.graphics.draw( canvases.entities, 0, 0 )
    love.graphics.draw( canvases.effects, 0, 0 )

    laserBloom:predraw()
    laserBloom:enabledrawtobloom()
    love.graphics.draw( canvases.effects, 0, 0 )
    laserBloom:postdraw()

    shieldBloom:predraw()
    shieldBloom:enabledrawtobloom()
    p1:drawShield()
    shieldBloom:postdraw()

    if PAUSED then
        love.graphics.origin()
        local f = love.graphics.getFont()
        love.graphics.setNewFont( 56 )
        love.graphics.printf( "PAUSED", 0, H/2 - 42, W, "center" )
        love.graphics.setFont( f )
    end
end

--------------
-- Controls --
--------------

function love.joystickadded( joystick )
    if p1.controller.joystick == nil or not p1.controller.joystick:isConnected() then
        p1.controller = GamepadController:new( p1, joystick, p1.controller.keymap )
    end
end

function love.joystickremoved( joystick )
    if joystick == p1.joystick then
        p1.joystick = nil
    end
end

function love.keypressed( key )
    p1.controller:buttondown( key )

    if not DEBUG then
        return
    end

    if key == "\\" then
        colorTestRender = not colorTestRender
    end

    if key == "[" then
        laserDebug = not laserDebug
        laserBloom:debugDraw( laserDebug )
    end
    if key == "]" then
        shieldDebug = not shieldDebug
        shieldBloom:debugDraw( shieldDebug )
    end
    if key == ";" then
        p1.shields = p1.shields - 1
    end
    if key == "'" then
        p1.shields = p1.shields + 1
    end
    if key == "/" then
        p1.shields = p1.maxShields
    end
    if key == "=" then
        p1.shields = 0
        p1:die()
    end

    if key == "," then
        prevBG()
    end
    if key == "." then
        nextBG()
    end
end

function love.keyreleased( key )
    p1.controller:buttonup( key )
end

function love.gamepadpressed( joystick, button )
    if joystick == p1.controller.joystick then
        p1.controller:buttondown( button )
    end

    if button == "dpup" or button == "dpright" then
        nextBG()
    elseif button == "dpdown" or button == "dpleft" then
        prevBG()
    end

    if button == "back" then
        RESET()
    end
end

function love.gamepadreleased( joystick, button )
    if joystick == p1.joystick then
        p1:buttonup( button )
    end
end
