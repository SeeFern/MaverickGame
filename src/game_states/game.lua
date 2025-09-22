local sfx = {}
	sfx.success = la.newSource('assets/sfx/end.wav', 'static')
	sfx.jump = la.newSource('assets/sfx/jump.wav', 'static')
	sfx.grav_inv = la.newSource('assets/sfx/grav_inv.wav', 'static')
	sfx.hit = la.newSource('assets/sfx/hit.wav', 'static')
	sfx.heal = la.newSource('assets/sfx/snack.wav', 'static')
	sfx.smash = la.newSource('assets/sfx/smash.wav', 'static')

local music = {}
	music.music1 = la.newSource('assets/music/music1.ogg', 'static')
	music.music2 = la.newSource('assets/music/music2.ogg', 'static')
	music.music3 = la.newSource('assets/music/music3.ogg', 'static')
	music.music4 = la.newSource('assets/music/music4.ogg', 'static')
	music.music5 = la.newSource('assets/music/music5.ogg', 'static')

local img = {}
	img.background = lg.newImage('assets/sprites/background.png')
	img.fog = lg.newImage('assets/sprites/fog.png')
	img.heart = lg.newImage('assets/sprites/heart.png')

local fog_x, fog_y = 0, 0
local bg_color_web = {93, 152, 140}
local bg_color_desktop = {0.37,0.60,0.55}
local frame, score = 0, 0
local chelsea_shown, chelsea_x = true, 65
local dialogue, start_timer = 1, 0

local music_tracks = {music.music1, music.music2, music.music3, music.music4, music.music5}
local playlist = {}
local current_track_index = 1
local current_track, next_track = nil, nil
local fade_duration = 2
local fade_timer = 0
local fading = false

local function shuffle_tracks(tracks)
    local t = {}
    for i = 1, #tracks do t[i] = tracks[i] end
    for i = #t, 2, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

local function play_next_track()
    if current_track_index > #playlist then
        playlist = shuffle_tracks(music_tracks)
        current_track_index = 1
    end

    local track_to_play = playlist[current_track_index]
    track_to_play:setVolume(0)
    track_to_play:setLooping(false)
    track_to_play:play()

    if current_track then
        next_track = track_to_play
        fade_timer = 0
        fading = true
    else
        -- First track: play immediately
        current_track = track_to_play
        current_track:setVolume(1)
        next_track = nil
        fading = false
    end

    current_track_index = current_track_index + 1
end


local function reset_game()
    game_started = false
    player.y = 96
    chelsea_shown = true
    dialogue = 1
    player.health = 3
    player.isSmashing = false
    player.grounded = true
    tile_speed_timer = 0
    player.iframes = 0
    flip_timer = 0
    spin_timer = 0
    invert_timer = 0
    score = 0
    chelsea_x = 65
end


local G = {}


function G.init()

	reset_game()

    -- Load map and entities
    map_manager = require("src.map")
    map_manager.init()
    signal.emit("random fog")
    require("src.entities.player")
    require("src.effects")

    -- Initialize playlist and start music
    playlist = shuffle_tracks(music_tracks)
    current_track_index = 1
    current_track, next_track = nil, nil
    play_next_track()
end


function G.update(dt)

    player_update(dt)
    update_boxes(dt)
    update_effects(dt)

    if fading and current_track and next_track then
        fade_timer = fade_timer + dt
        local t = math.min(fade_timer / fade_duration, 1)
        current_track:setVolume(1 - t)
        next_track:setVolume(t)

        if t >= 1 then
            current_track:stop()
            current_track = next_track
            next_track = nil
            fading = false
        end
    elseif current_track and not current_track:isPlaying() then
        play_next_track()
    end

    if chelsea_shown then
        chelsea.animation:update(dt)
        if game_started then
            chelsea_x = chelsea_x - tile_speed * dt
        end
    end
    if chelsea_x <= -20 then chelsea_shown = false end

    fog_x = fog_x - 5 * dt
    if fog_x <= -320 then fog_x = 160 signal.emit("random fog") end

    if sped_up then
        tile_speed_timer = tile_speed_timer - dt
        if tile_speed_timer <= 0 then
            sped_up = false
            tile_speed = 100
            tile_speed_timer = 0
            frame_between_tiles = 6
        end
    end

    frame = frame + 1

    if player.health <= 0 and game_started then
        game_started = false
        switchState("main_menu")
        signal.emit("print score", score)
    end

    if game_started then
        map_manager.update_tiles(dt)
        if frame >= frame_between_tiles then
            map_manager.generate_tiles()
            frame = 0
        end
        score = score + dt
    end

    if not game_started and dialogue == 2 and start_timer > 0 then
        start_timer = start_timer - dt
    end

    map_manager.destroy_tiles()
end


function G.draw()
    lg.clear()
    lg.setBackgroundColor(0.37,0.60,0.55)
    lg.draw(img.background, 0, 0)
    lg.draw(img.fog, fog_x, fog_y)
    map_manager.draw_tiles()
    draw_player()
    if chelsea_shown then
        chelsea.animation:draw(bigSprites.bigChelsSheet, chelsea_x, 90, nil, -1, 1)
    end
end


function G.ui()

    if not canvas_flipped then
        lg.setColor(0,0,0)
        lg.printf("Score: "..math.floor(score), 0, 8, love.graphics.getWidth(), "right")
        lg.setColor(1,1,1)
    else
        lg.printf("Score: "..math.floor(score), 0, 8, love.graphics.getWidth(), "right")
    end

    if not game_started then
        lg.setColor(0,0,0)
        lg.rectangle("fill", 280, 300, 355, 100)
        lg.setColor(1,1,1)
        lg.setFont(sm_game_font)
        if dialogue == 1 then
            lg.print("Ok Maverick, use A to jump and\nB to smash crates.\nGrab some snacks along the way.", 290, 310)
        else
            lg.print("Watch out for those weird snack\neffects though. When you're ready,\npress A to go!", 290, 310)
        end
        lg.setFont(game_font)
    end

    for i = 1, player.health do
        lg.draw(img.heart, (i-1) * 32, 8)
    end
end


function G.keypressed(key)
	if key == "escape" then switchState("main_menu") signal.emit("print score", score) end
	if key == "z" and not game_started then
		if dialogue == 1 then
			dialogue = 2
			start_timer = 0.25
		else
			player.grounded = false
			game_started = true
		end
	end
	if not controls_inverted then
		if game_started and player.grounded then
			if key == "up" then
				pcall(function() sfx.jump:play() end)
				player_jump()
			end
			if key == "z" then
				player.isSmashing = true
			end
		end
	else
		if game_started and player.grounded then
			if key == "z" then
				pcall(function() sfx.jump:play() end)
				player_jump()
			end
			if key == "up" then
				player.isSmashing = true
			end
		end
	end
end


function G.gamepadpressed(button)
	if button == "back" then switchState("main_menu") signal.emit("print score", score) end
	if button == "a" and not game_started then
		if dialogue == 1 then
			dialogue = 2
			start_timer = 0.25
		else
			player.grounded = false
			game_started = true
		end
	end
	if not controls_inverted then
		if game_started and player.grounded then
			if button == "a" then
				pcall(function() sfx.jump:play() end)
				player_jump()
			end
			if button == "b" then
				player.isSmashing = true
			end
		end
	else
		if game_started and player.grounded then
			if button == "b" then
				pcall(function() sfx.jump:play() end)
				player_jump()
			end
			if button == "a" then
				player.isSmashing = true
			end
		end
	end
end


function G.mousepressed(x, y, button)
    if button ~= 1 then return end -- Only respond to left click / tap

    if not game_started then
        if dialogue == 1 then
            dialogue = 2
            start_timer = 0.25
        else
            player.grounded = false
            game_started = true
        end
        return
    end

    if game_started and player.grounded then
        local screenWidth = love.graphics.getWidth()

        if not controls_inverted then
            if x < screenWidth / 2 then
                player.isSmashing = true
            else
                pcall(function() sfx.jump:play() end)
                player_jump()
            end
        else
            if x < screenWidth / 2 then
                pcall(function() sfx.jump:play() end)
                player_jump()
            else
                player.isSmashing = true
            end
        end
    end
end


signal.register("random chaos", function() random_chaos() end)
signal.register("random fog", function() fog_y = math.random(-100,-50) end)

signal.register("player hit", function()
    player.iframes = 30
    player.health = player.health - 1
    pcall(function() sfx.hit:stop() sfx.hit:play() end)
end)

signal.register("player heal", function()
    player.iframes = 30
    score = score + 5
    if player.health < 3 then player.health = player.health + 1 end
    pcall(function() sfx.heal:stop() sfx.heal:play() end)
end)

signal.register("smash", function()
    pcall(function() sfx.smash:stop() sfx.smash:play() score = score + 2 end)
end)

signal.register("speed up", function()
    if not sped_up then
        sped_up = true
        tile_speed = tile_speed + 50
        tile_speed_timer = 3
        frame_between_tiles = 3
    end
end)

return G
