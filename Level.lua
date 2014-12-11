local Core = require "Core"
local Cell = require "Cell"

local Level = Core.class()

function Level:init(width, height, wall, floor)
    self.width, self.height = width, height
    local cells = {}
    for x = 1, width do
        cells[x] = {}
        for y = 1, height do
            local terrain = self:isOnBorder(x, y) and wall or floor
            cells[x][y] = Cell.new(self, x, y, terrain)
        end
    end
    self.cells = cells
end

function Level:at(x, y)
    local column = self.cells[x]
    return column and column[y]
end

function Level:isOnBorder(x, y)
    return (1 == x) or (x == self.width) or (1 == y) or (y == self.height)
end

return Level
