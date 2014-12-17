require( "ext/cupid" )

function love.conf( t )
    t.identity = "Prism"
    t.version = "0.9.1"
    t.author = "@aranasaurus"

    t.window.highdpi = false
    t.window.title = "Prism"
    t.window.width = 1280
    t.window.height = 720

    t.modules.physics = false
end
