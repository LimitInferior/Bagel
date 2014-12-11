local Core = require "Core"

local Direction = Core.class()

function Direction:init(x, y)
    self.x = x
    self.y = y
end

Direction.left = Direction.new(-1, 0)
Direction.right = Direction.new(1, 0)
Direction.up = Direction.new(0, -1)
Direction.down = Direction.new(0, 1)

Direction.directions = {Direction.left, Direction.right, Direction.up, Direction.down}

function Direction.random()
    return Direction.directions[love.math.random(1, #Direction.directions)]
end

return Direction
