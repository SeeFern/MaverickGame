jit.off()
require("globals")
require("src.effects")

signal = require 'libraries/hump/signal'
anim8 = require 'libraries/anim8/anim8'

local main_menu = require("src.game_states.main_menu")
local game = require("src.game_states.game")
local states = {}

local sfx = {}
	sfx.controls_inv = la.newSource('assets/sfx/controls_inv.wav', 'static')

curr_state = nil
game_started = false
canvas_flipped = false
canvas_spun = false
flip_timer = 0
spin_timer = 0
canvas_x_scale = 1
canvas_y_scale = 1
controls_inverted = false
invert_timer = 0

function switchState(state_name)
	pcall(function() la.stop() end)
	curr_state = states[state_name]
	if curr_state and curr_state.init then
		curr_state.init()
	end
end

function love.load()
	math.randomseed(os.time())

	virtualWidth, virtualHeight = 160, 144
	scaleFactor = 4
	windowWidth, windowHeight = virtualWidth * scaleFactor, virtualHeight * scaleFactor

	gameCanvas = lg.newCanvas(virtualWidth, virtualHeight)
	gameCanvas:setFilter("nearest", "nearest")
	lg.setDefaultFilter("nearest", "nearest")

	lw.setMode(windowWidth, windowHeight, {resizable = false, vsync = true})

	local joysticks = love.joystick.getJoysticks()
	joystick = joysticks[1]
	controls_inverted = false

	game_font = lg.setNewFont('assets/fonts/pixel.ttf', 50)
	sm_game_font = lg.setNewFont('assets/fonts/pixel.ttf', 30)
	lg.setFont(game_font)
	lms.setVisible(false)

	states.main_menu = main_menu
	states.game_play = game

	switchState('main_menu')
end

function love.update(dt)
	if curr_state and curr_state.update then
		curr_state.update(dt)
	end

	if canvas_flipped then
		flip_timer = flip_timer - dt
		if flip_timer <= 0 then
			canvas_flipped = false
			canvas_y_scale = 1
			flip_timer = 0
		end
	end
	if canvas_spun then
		spin_timer = spin_timer - dt
		if spin_timer <= 0 then
			canvas_spun = false
			canvas_x_scale = 1
			spin_timer = 0
		end
	end
	if controls_inverted then
		invert_timer = invert_timer - dt
		if invert_timer <= 0 then
			controls_inverted = false
			invert_timer = 0
			sfx.controls_inv:stop()
			sfx.controls_inv:setPitch(0.5)
			sfx.controls_inv:play()
		end
	end
end

function love.draw()
    love.graphics.setColor(color_modulation.r, color_modulation.g, color_modulation.b)

    lg.setCanvas(gameCanvas)
    lg.setFont(game_font)

    if curr_state and curr_state.draw then
        curr_state.draw()
    end
    lg.setCanvas()

    lg.push()
		lg.scale(scaleFactor, scaleFactor)

		local draw_x_scale = canvas_spun and -1 or 1
		local draw_y_scale = canvas_flipped and -1 or 1

		local translate_x = draw_x_scale == -1 and virtualWidth or 0
		local translate_y = draw_y_scale == -1 and virtualHeight or 0

		lg.push()
			lg.translate(translate_x, translate_y)
			lg.scale(draw_x_scale, draw_y_scale)
			lg.draw(gameCanvas, 0, 0)
		lg.pop()
    lg.pop()

    if curr_state and curr_state.ui then
        curr_state.ui()
    end

    love.graphics.setColor(1, 1, 1)
end



function love.keypressed(key)
	if curr_state and curr_state.keypressed then
		curr_state.keypressed(key)
	end
end

function love.gamepadpressed(joystick, button)
	if curr_state and curr_state.gamepadpressed then
		curr_state.gamepadpressed(button)
	end
end

function love.mousepressed(x, y, button)
	if curr_state and curr_state.mousepressed then
		curr_state.mousepressed(x, y, button)
	end
end

--TODO: end screen for when you lose
--TODO: any other polish like fixing art for hearts.
--TODO: add touchscreen controls
--TODO: try to get an android build out as well.
--TODO: get web build working
--TODO: write up instructions for playing on muOS with included files
