local effect_sounds = {}
	effect_sounds.grav_inv = la.newSource('assets/sfx/grav_inv.wav', 'static')
	effect_sounds.color_change = la.newSource('assets/sfx/color_change.wav', 'static')
	effect_sounds.speed_up = la.newSource('assets/sfx/swoosh.ogg', 'static')
	effect_sounds.spin = la.newSource('assets/sfx/spin.wav', 'static')
	effect_sounds.controls_inv = la.newSource('assets/sfx/controls_inv.wav', 'static')

local color_timer = 0
local color_effect_active = false
color_modulation = {r = 1, g = 1, b = 1}
local target_modulation = {r = 1, g = 1, b = 1}
local shift_interval = 0.1
local shift_timer = 0


local function random_color()
	return {
		r = love.math.random(),
		g = love.math.random(),
		b = love.math.random()
	}
end


local function invert_controls(duration)
	pcall(function()
		pcall(function() effect_sounds.controls_inv:stop() end)
		effect_sounds.grav_inv:setVolume(0.5)
		pcall(function() effect_sounds.controls_inv:play() end)

		controls_inverted = true
		invert_timer = duration
    end)
end

local function flip_canvas(duration)
	pcall(function()
		pcall(function() effect_sounds.grav_inv:stop() end)
		effect_sounds.grav_inv:setVolume(0.5)
		pcall(function() effect_sounds.grav_inv:play() end)

		canvas_flipped = true
		flip_timer = duration
	end)
end

local function spin_canvas(duration)
	pcall(function()
		pcall(function() effect_sounds.spin:stop() end)
		effect_sounds.grav_inv:setVolume(0.5)
		pcall(function() effect_sounds.spin:play() end)

		canvas_spun = true
		spin_timer = duration
	end)
end

local function speed_up()
	signal.emit("speed up")
	pcall(function() effect_sounds.speed_up:stop() end)
	pcall(function() effect_sounds.speed_up:play() end)
end


local function color_shift(duration)
	color_effect_active = true
	color_timer = duration
	shift_timer = 0
	color_modulation = random_color()
	target_modulation = random_color()

	pcall(function()
		effect_sounds.color_change:stop()
		effect_sounds.color_change:play()
	end)
end


function random_chaos()
	local rnd = math.random(0, 6)
	if rnd == 0 then
		flip_canvas(3)
	elseif rnd == 1 then
		speed_up()
	elseif rnd == 2 then
		color_shift(6)
	elseif rnd == 3 then
		spin_canvas(3)
	elseif rnd == 4 then
		invert_controls(3)
	end
end


function update_effects(dt)
	if color_effect_active then
		color_timer = color_timer - dt
		shift_timer = shift_timer - dt

		if shift_timer <= 0 then
			target_modulation = random_color()
			shift_timer = shift_interval
		end

		local lerp_speed = dt * 2
		color_modulation.r = color_modulation.r + (target_modulation.r - color_modulation.r) * lerp_speed
		color_modulation.g = color_modulation.g + (target_modulation.g - color_modulation.g) * lerp_speed
		color_modulation.b = color_modulation.b + (target_modulation.b - color_modulation.b) * lerp_speed

		if color_timer <= 0 then
			color_effect_active = false
			color_modulation = {r = 1, g = 1, b = 1}
		end
	end
end
