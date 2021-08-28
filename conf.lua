-- TODO: Re-enable this after I figure out if there's a version that runs on 0.11
-- require( "ext/cupid" )

function love.conf( t )
    t.identity = "Prism"
    t.version = "11.3"
    t.author = "@aranasaurus"

    t.window.highdpi = false
    t.window.title = "Prism"
    t.window.width = 1280
    t.window.height = 720

    t.modules.physics = false
end
