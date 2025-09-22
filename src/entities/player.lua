require("src.map")
local collision = require("libraries/collision")

local sprites = {}
	sprites.playerSheet = lg.newImage('assets/sprites/playerSheet.png')

local grid = anim8.newGrid(16, 16, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
local smash_timer = 0
local smash_duration = 0.5

local animations = {}
	animations.idle = anim8.newAnimation(grid('1-4', 3), 0.1)
	animations.jump = anim8.newAnimation(grid('6-6', 3), 1.0)
	animations.fall = anim8.newAnimation(grid('3-3', 4), 1.0)
	animations.run = anim8.newAnimation(grid('1-6', 2), 0.1)
	animations.smash = anim8.newAnimation(grid('2-2', 4), 1.0)

local min_grav = 400


player = {}
	player.x = 18
	player.y = 96
	player.vy = 0
	player.width = 16
	player.height = 16
	player.animation = animations.idle
	player.direction = 1
	player.grounded = true
	player.yscale = 1
	player.gravity = min_grav
	player.health = 3
	player.iframes = 0
	player.isSmashing = false
	player.jump_force = -150


function player_update(dt)
	grav(dt)
	player.y = player.y + player.vy * dt

	for _, t in ipairs(tiles) do
		if collision.check(player, t) then
			collision.resolve(player, t)
			player.grounded = true
		end
	end

	for i = #boxes, 1, -1 do
		local b = boxes[i]
		if not b.breaking and collision.check(player, b) and player.iframes <= 0 then
			if player.isSmashing == false then
				signal.emit("player hit")
			else
				signal.emit("smash")
				-- Start flickering effect
				b.breaking = true
				b.break_timer = 0.25
				b.visible = true
			end
		end
	end

	for _, r in ipairs(rocks) do
		if collision.check(player, r) and player.iframes <= 0 then
			signal.emit("player hit")
		end
	end

	for i = #foods, 1, -1 do
		local f = foods[i]
		if collision.check(player, f) and player.iframes <= 0 then
			signal.emit("player heal")
			random_chaos()
			table.remove(foods, i)
		end
	end

	update_player_animation(dt)

	if player.iframes > 0 then
		player.iframes = player.iframes - 1
	end

	player.animation:update(dt)
end


function draw_player()
	lg.setColor(1, 1, 1)
	if player.iframes <= 0 or player.iframes % 2 == 0 then
		player.animation:draw(sprites.playerSheet, player.x, player.y, nil, 1 * player.direction, player.yscale, 0, 0)
	end
end


function grav(dt)
	-- Apply gravity
	if not player.grounded then
		player.vy = player.vy + player.gravity * dt
		smash_timer = 0
		smash_duration = 0.5
		player.isSmashing = false
	else
		player.vy = 0
	end
end


function update_player_animation(dt)
	if game_started == false then
		player.animation = animations.idle
		return
	end
	if player.grounded then
		if player.isSmashing then
			player.animation = animations.smash
			smash_timer = smash_timer + dt
			if smash_timer >= smash_duration then
				player.isSmashing = false
				smash_timer = 0
			end
		else
			player.animation = animations.run
		end
	else
		if player.vy < 0 then
			player.animation = animations.jump
		else
			player.animation = animations.fall
		end
	end
end


function player_jump()
	player.vy = player.jump_force
	player.isSmashing = false
	player.grounded = false
end
