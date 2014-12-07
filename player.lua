require "vector"

player = {}

function createPlayer()
    local sticks = love.joystick.getJoysticks()

    player = {
        pos = Vector:new( W/2, H/2 ),
        mov = Vector:new( 0, 0 ),
        movGoal = Vector:new( 0, 0 ),
        facing = Vector:new( 1, 0 ),
        w = 48,
        h = 32,
        joystick = sticks[1]
    }
end

function drawPlayer()
    love.graphics.push()
    love.graphics.translate( player.pos.x, player.pos.y )
    love.graphics.rotate( player.facing:angle() )

    love.graphics.setColor( 255, 0, 0 )
    love.graphics.polygon( "fill", -player.w/2, -player.h/2, player.w/2, 0, -player.w/2, player.h/2 )
    if player.debugText ~= nil then
        love.graphics.printf( player.debugText, -player.w/2, -player.h, player.w, "left", 0, love.window.getPixelScale(), love.window.getPixelScale() )
    end
    love.graphics.pop()
end

function updatePlayer( dt )
    if player.joystick ~= nil then
        local leftInput = Vector:new( player.joystick:getGamepadAxis( "leftx" ), player.joystick:getGamepadAxis( "lefty" ) )
        local rightInput = Vector:new( player.joystick:getGamepadAxis( "rightx" ), player.joystick:getGamepadAxis( "righty" ) )

        if leftInput:length() < DEAD_ZONE then
            leftInput.x = 0
            leftInput.y = 0
        end
        if rightInput:length() < DEAD_ZONE then
            rightInput = player.facing
        end

        player.mov = leftInput
        player.mov:multiply( MAX_PLAYER_VEL * dt )
        player.facing = rightInput

        player.pos:add( player.mov )
    end

    local s = math.max( player.w, player.h)/2 + 4
    player.pos.x = math.min( player.pos.x, W - s )
    player.pos.x = math.max( player.pos.x, s )
    player.pos.y = math.min( player.pos.y, H - s )
    player.pos.y = math.max( player.pos.y, s )
end

function fireLaser()
    table.insert( lasers, Laser:new( player.pos, player.facing ) )
end
