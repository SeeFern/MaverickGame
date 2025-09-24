function love.conf(t)
    t.version = "11.5"
    t.accelerometerjoystick = false
    t.externalstorage = true
    t.audio.mixwithsystem = false
    t.window.title = "Run Maverick, Run!"
    t.window.icon = 'assets/sprites/icon.png'
    t.window.width = 640
    t.window.height = 576
    t.modules.physics = false
    t.modules.thread = false
    t.modules.video = false
end
