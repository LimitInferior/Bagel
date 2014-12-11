local Core = require "Core"

local Cell = Core.class()

function Cell:init(level, x, y, terrain)
    self.level = level
    self.x, self.y = x, y
    self.terrain = terrain
end

function Cell:getAdjacent(direction)
    return self.level:at(self.x + direction.x, self.y + direction.y)
end

function Cell:canPlaceUnit()
    return self.terrain.isWalkable and (self.unit == nil)
end

return Cell
