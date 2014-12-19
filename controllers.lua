require "vector"

KeyboardController = {}
GamepadController = {}

function KeyboardController:new( player, keymap )
    local c = {}
    setmetatable( c, self )
    self.__index = self

    c.player = player
    local defaultKeymap = {
        vel_h = { "a", "d" },
        vel_v = { "w", "s" },
        change_shield = "e",
        change_ship = "q",
        rot = { "left", "right" },
        fire = "up",
        flip = "down",
        pause = " "
    } 
    c.keymap = keymap or defaultKeymap
    -- ensure we have a binding for all of the required keys in the map
    if keymap then
        for k, v in pairs( defaultKeymap ) do
            c.keymap[k] = c.keymap[k] or v
        end
    end
    c.rotation_rate = math.pi * 2

    c.vel = vector( 0, 0 )

    return c
end

function KeyboardController:buttondown( button )
    if button == self.keymap.vel_h[1] then
        self.vel.x = -1
    elseif button == self.keymap.vel_h[2] then
        self.vel.x = 1
    elseif button == self.keymap.vel_v[1] then
        self.vel.y = -1
    elseif button == self.keymap.vel_v[2] then
        self.vel.y = 1
    elseif button == self.keymap.change_ship then
        self.player:nextColor()
    elseif button == self.keymap.change_shield then
        self.player:nextShieldColor()
    elseif button == self.keymap.pause then
        PAUSED = not PAUSED
    elseif button == self.keymap.flip then
        self.flip = true
    end

end

function KeyboardController:buttonup( button )
    if button == self.keymap.vel_h[1] or button == self.keymap.vel_h[2] then
        -- only set to 0 if both keys are not pressed
        if not love.keyboard.isDown( self.keymap.vel_h[1], self.keymap.vel_h[2] ) then
            self.vel.x = 0
        end
    elseif button == self.keymap.vel_v[1] or button == self.keymap.vel_v[2] then
        -- only set to 0 if both keys are not pressed
        if not love.keyboard.isDown( self.keymap.vel_v[1], self.keymap.vel_v[2] ) then
            self.vel.y = 0
        end
    end

    if button == self.keymap.flip then
        self.flip = false
    end
end

function KeyboardController:getVelocity()
    return self.vel
end

function KeyboardController:getRotation( dt )
    local rotMod = 0
    if love.keyboard.isDown( self.keymap.rot[1] ) then
        rotMod = -1
    elseif love.keyboard.isDown( self.keymap.rot[2] ) then
        rotMod = 1
    end

    local rot = self.player.rot + (rotMod * self.rotation_rate * dt)
    if self.flip then
        rot = rot + math.pi
        self.flip = false
    end
    return rot
end

function KeyboardController:isFiring()
    return love.keyboard.isDown( self.keymap.fire )
end

------------------------
-- Gamepad Controller --
------------------------

function GamepadController:new( player, joystick, keymap )
    local c = {}
    setmetatable( c, self )
    self.__index = self

    c.player = player
    c.joystick = joystick
    local defaultKeymap = {
        vel_v = "lefty",
        vel_h = "leftx",
        change_shield = "rightshoulder",
        change_ship = "leftshoulder",
        rot_v = "righty",
        rot_h = "rightx",
        fire = "right",
        pause = "start"
    }

    c.keymap = keymap or defaultKeymap
    -- ensure we have a binding for all of the required keys in the map
    if keymap then
        for k, v in pairs( defaultKeymap ) do
            c.keymap[k] = c.keymap[k] or v
        end
    end

    return c
end

function GamepadController:getRotation( dt )
    local rotInput = vector( self.joystick:getGamepadAxis( self.keymap.rot_h ), self.joystick:getGamepadAxis( self.keymap.rot_v ) )
    if rotInput:length() < DEAD_ZONE then
        return 0
    end
    return rotInput:angle()
end

function GamepadController:getVelocity()
    local velInput = vector( self.joystick:getGamepadAxis( self.keymap.vel_h ), self.joystick:getGamepadAxis( self.keymap.vel_v ) )
    if velInput:length() < DEAD_ZONE then
        return vector( 0, 0 )
    end
    return velInput
end

function GamepadController:isFiring()
    local rotInput = vector( self.joystick:getGamepadAxis( self.keymap.fire .. "x" ), self.joystick:getGamepadAxis( self.keymap.fire .. "y" ) )
    return rotInput:length() > DEAD_ZONE
end

function GamepadController:buttondown( button )
    if button == self.keymap.change_ship then
        self.player:nextColor()
    end
    if button == self.keymap.change_shield then
        self.player:nextShieldColor()
    end

    if button == self.keymap.pause then
        PAUSED = not PAUSED
    end
end

function GamepadController:buttonup( button )

end
