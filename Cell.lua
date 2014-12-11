local Core = require "Core"

local Cell = Core.class()

function Cell:init(level, x, y, terrain)
    self.level = level
    self.x, self.y = x, y
    self.terrain = terrain
end

return Cell
