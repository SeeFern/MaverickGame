local music = {}
	music.menu = la.newSource('assets/music/menu_music.ogg', "static")

local img = {}
	img.bg = lg.newImage('assets/sprites/menu.png')

bigSprites = {}
	bigSprites.bigPlayerSheet = lg.newImage('assets/sprites/playerSheet.png')
	bigSprites.bigChelsSheet = lg.newImage('assets/sprites/chels.png')

local bigGrid = anim8.newGrid(16, 16, bigSprites.bigPlayerSheet:getWidth(), bigSprites.bigPlayerSheet:getHeight())
bigChelsGrid = anim8.newGrid(16, 22, bigSprites.bigChelsSheet:getWidth(), bigSprites.bigChelsSheet:getHeight())

bigAnimations = {}
	bigAnimations.idle = anim8.newAnimation(bigGrid('1-4', 3), 0.1)
	bigAnimations.chels_idle = anim8.newAnimation(bigChelsGrid('1-2', 1), 0.6)

chelsea = {}
	chelsea.x = 18
	chelsea.y = 96
	chelsea.width = 16
	chelsea.height = 16
	chelsea.animation = bigAnimations.chels_idle
	chelsea.direction = -1

local last_score = 0
local print_score = false

local M = {

	init = function()
		game_started = false
		controls_inverted = false
		require("src.entities.player")
		player.animation = bigAnimations.idle
		pcall(function() music.menu:stop() end)
			music.menu:setLooping(true)
		pcall(function() music.menu:play() end)

	bigSprites = {}
		bigSprites.bigPlayerSheet = lg.newImage('assets/sprites/playerSheet.png')
		bigSprites.bigChelsSheet = lg.newImage('assets/sprites/chels.png')

	bigChelsGrid = anim8.newGrid(16, 22, bigSprites.bigChelsSheet:getWidth(), bigSprites.bigChelsSheet:getHeight())

	bigAnimations = {}
		bigAnimations.idle = anim8.newAnimation(bigGrid('1-4', 3), 0.1)
		bigAnimations.chels_idle = anim8.newAnimation(bigChelsGrid('1-2', 1), 0.6)

	chelsea = {}
		chelsea.x = 18
		chelsea.y = 96
		chelsea.width = 16
		chelsea.height = 16
		chelsea.animation = bigAnimations.chels_idle
		chelsea.direction = -1
	end,


	update = function(dt)
		player.animation:update(dt)
		chelsea.animation:update(dt)
	end,


	draw = function()
		lg.clear(0,0,0)
		love.graphics.setColor(1, 1, 1)
		lg.draw(img.bg,0 ,0)
		player.animation:draw(bigSprites.bigPlayerSheet, 75, 76, nil, 1*player.direction, player.yscale, 8,8)
		chelsea.animation:draw(bigSprites.bigChelsSheet, 95, 62, nil, -1, 1)
	end,


	ui = function()
		lg.printf("Run Maverick, Run!", 0, 105, lg.getWidth(), "center")
		lg.printf("A to start", 0, 379, lg.getWidth(), "center")
		if print_score then lg.printf("Final Score: "..math.floor(last_score), 0, 200, lg.getWidth(), "center") end
	end,


	keypressed = function(key)
		if key == "escape" then love.event.quit() end
		if key == "z" then
			switchState("game_play")
		end
	end,


	gamepadpressed = function(button)
		if button == 'a' then
			switchState("game_play")
		end
	end,


	mousepressed = function(x, y, button)
		if button == 1 then
			switchState("game_play")
		end
	end,


	signal.register("print score", function(score)
		print_score = true
		if type(score) == "number" then
			last_score = score
		end
	end)

}

return M
