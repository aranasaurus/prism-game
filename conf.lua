require( "ext/cupid" )

function love.conf( t )
    t.identity = "HitBox"
    t.version = "0.9.1"
    t.author = "@aranasaurus"

    t.window.highdpi = true
    t.window.title = "HitBox"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.borderless = false

    t.modules.physics = false
end
