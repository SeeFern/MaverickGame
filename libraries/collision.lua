local collision = {}


function collision.check(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end


function collision.resolve(a, b)
    local dx = (a.x + a.width / 2) - (b.x + b.width / 2)
    local dy = (a.y + a.height / 2) - (b.y + b.height / 2)
    local overlapX = (a.width + b.width) / 2 - math.abs(dx)
    local overlapY = (a.height + b.height) / 2 - math.abs(dy)

    if overlapX > 0 and overlapY > 0 then
        if overlapX < overlapY then
            if dx > 0 then
                a.x = a.x + overlapX
            else
                a.x = a.x - overlapX
            end
        else
            if dy > 0 then
                a.y = a.y + overlapY
            else
                a.y = a.y - overlapY
            end
        end
    end
end


function collision.distanceBetween(obj_1, obj_2)
	return math.sqrt((obj_2.x - obj_1.x)^2 + (obj_2.y - obj_1.y)^2)
end

return collision
