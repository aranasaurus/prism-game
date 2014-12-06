DEAD_ZONE = 0.15

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
player = {}
bullets = {}
enemies = {}
buffs = {}

function reset()
    local sticks = love.joystick.getJoysticks()
    player = {
        x = W/2,
        y = H/2,
        rot = 0,
        w = 40,
        h = 32,
        v = 600,
        joystick = sticks[1]
    }

end

function drawPlayer()
    love.graphics.push()
    love.graphics.translate( player.x, player.y )
    love.graphics.rotate( player.rot )

    love.graphics.setColor( 255, 0, 0 )
    love.graphics.polygon( "fill", -player.w/2, -player.h/2, player.w, 0, -player.w/2, player.h/2 )
    love.graphics.pop()
end

function updatePlayer( dt )
    if player.joystick ~= nil then
        -- Movement
        local lx = player.joystick:getGamepadAxis( "leftx" )
        local ly = player.joystick:getGamepadAxis( "lefty" )

        if math.abs(lx) >= DEAD_ZONE then
            player.x = player.x + lx * player.v * dt
        end
        if math.abs(ly) >= DEAD_ZONE then
            player.y = player.y + ly * player.v * dt
        end

        -- Facing
        local rx = player.joystick:getGamepadAxis( "rightx" )
        local ry = player.joystick:getGamepadAxis( "righty" )

        if math.abs(rx) >= DEAD_ZONE or math.abs(ry) >= DEAD_ZONE then
            player.rot = -math.atan2( rx, ry ) + math.pi/2
        end
    end
end

function drawBullets()
end

function drawEnemies()
end

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
end

function love.draw()
    drawPlayer()
    drawBullets()
    drawEnemies()
    drawBuffs()
    drawStats()
end

function love.joystickadded( joystick )
    if player.joystick == nil or not player.joystick:isConnected() then
        player.joystick = joystick
    end
end

