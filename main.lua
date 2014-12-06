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
        local w, h = love.graphics.getDimensions()
        local f = love.graphics.getFont()

        if t - lastUpdate > updateInterval then
            lastUpdate = t
            memCount = collectgarbage( "count" )
        end
        local stats = string.format(statsFmt, love.timer.getFPS(), memCount )
        love.graphics.printf( stats, 10, 10, w - 20, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
    end
end

----------
-- Löve --
----------
function love.load( arg ) 
end

function love.update( dt )
    t = t + dt
end

function love.draw()
    drawStats()
end

