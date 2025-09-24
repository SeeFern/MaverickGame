local map_manager = {}

local collision = require("libraries.collision")
local tile_img = lg.newImage('/assets/sprites/tile.png')
local box_img = lg.newImage('/assets/sprites/box.png')
local rock_img = lg.newImage('/assets/sprites/rock.png')
local rnd = 0
local food_img = lg.newImage('/assets/sprites/strawberry.png')
local min_dist_between_obs = 112

tile_speed = 100
sped_up = false
tile_speed_timer = 0
frame_between_tiles = 6

function map_manager.init()
	tiles = {}
	boxes = {}
	rocks = {}
	foods = {}
    for i = 0, 11 do
		local tile = {}
			tile.x = i * 16
			tile.y = 112
			tile.width = 16
			tile.height = 48
		table.insert (tiles, tile)
    end
end


function map_manager.generate_tiles()
	rnd = math.random(40) --generate a number from 1 to 30
	if rnd > 26 and rnd < 31 then
		local box = {
			x = 176,
			y = 96,
			width = 16,
			height = 16,
			breaking = false,
			break_timer = 0,
			visible = true
		}
		local ok_to_insert = true
		if #rocks > 0 and collision.distanceBetween(box, rocks[#rocks]) < min_dist_between_obs then
			ok_to_insert = false
		end
		if #boxes > 0 and collision.distanceBetween(box, boxes[#boxes]) < min_dist_between_obs then
			ok_to_insert = false
		end
		if ok_to_insert then
			table.insert(boxes, box)
		end
	end
	if rnd > 22 and rnd < 27 then
		local rock = {
			x = 176,
			y = 103,
			width = 13,
			height = 9
		}
		local ok_to_insert = true
		if #boxes > 0 and collision.distanceBetween(rock, boxes[#boxes]) < min_dist_between_obs then
			ok_to_insert = false
		end
		if #rocks > 0 and collision.distanceBetween(rock, rocks[#rocks]) < min_dist_between_obs then
			ok_to_insert = false
		end
		if ok_to_insert then
			table.insert(rocks, rock)
		end
	end
	if rnd > 19 and rnd < 23 then
		local food = {
			x = 192,
			y = 80,
			width = 8,
			height = 8
		}
		local ok_to_insert = true
		if #foods > 0 and collision.distanceBetween(food, foods[#foods]) < min_dist_between_obs * 0.5 then
			ok_to_insert = false
		end
		if ok_to_insert then
			table.insert(foods, food)
		end
	end
    local tile = {}
		tile.x = 176
		tile.y = 112
		tile.width = 16
		tile.height = 32
    table.insert(tiles, tile)
end


function map_manager.update_tiles(dt)
    for _, t in ipairs(tiles) do
        t.x = t.x - tile_speed * dt
    end
    for _, b in ipairs(boxes) do
        b.x = b.x - tile_speed * dt
    end
    for _, r in ipairs(rocks) do
        r.x = r.x - tile_speed * dt
    end
    for _, f in ipairs(foods) do
        f.x = f.x - tile_speed * dt
    end
end


function map_manager.draw_tiles()
    for _, t in ipairs(tiles) do
		lg.draw(tile_img, t.x, t.y)
    end
    draw_boxes()
    for _, r in ipairs(rocks) do
		lg.draw(rock_img, r.x, r.y)
    end
    for _, f in ipairs(foods) do
		lg.draw(food_img, f.x, f.y)
    end
end


function map_manager.destroy_tiles()
    for t = #tiles, 1, -1 do
        if tiles[t].x <= -20 then
            table.remove(tiles, t)
        end
    end
    for b = #boxes, 1, -1 do
        if boxes[b].x <= -20 then
            table.remove(boxes, b)
        end
    end
    for r = #rocks, 1, -1 do
        if rocks[r].x <= -20 then
            table.remove(rocks, r)
        end
    end
    for f = #foods, 1, -1 do
        if foods[f].x <= -20 then
            table.remove(foods, f)
        end
    end
end


function update_boxes(dt)
	for i = #boxes, 1, -1 do
		local b = boxes[i]
		if b.breaking then
			b.break_timer = b.break_timer - dt
			if math.floor(b.break_timer * 20) % 2 == 0 then
				b.visible = false
			else
				b.visible = true
			end

			if b.break_timer <= 0 then
				table.remove(boxes, i)
			end
		end
	end
end


function draw_boxes()
	for _, b in ipairs(boxes) do
		if b.visible then
			lg.setColor(1, 1, 1)
			lg.draw(box_img, b.x, b.y)
		end
	end
end

return map_manager
