require( "ext/cupid" )

function love.conf( t )
    t.identity = "HitBox"
    t.version = "0.9.1"
    t.author = "@aranasaurus"

    t.window.highdpi = false
    t.window.title = "LightBox"
    t.window.width = 1280
    t.window.height = 720

    t.modules.physics = false
end
