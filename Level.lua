local Core = require "Core"
local Cell = require "Cell"

local Level = Core.class()

function Level:init(width, height, wall, floor)
    self.width, self.height = width, height
    self.wall, self.floor = wall, floor
    local cells = {}
    for x = 1, width do
        cells[x] = {}
        for y = 1, height do
            local terrain = self:isOnBorder(x, y) and wall or floor
            cells[x][y] = Cell.new(self, x, y, terrain)
        end
    end
    self.cells = cells
    self.units = {}
    self.activeUnitIndex = 1
    self.now = 0
end

function Level:at(x, y)
    local column = self.cells[x]
    return column and column[y]
end

function Level:isOnBorder(x, y)
    return (1 == x) or (x == self.width) or (1 == y) or (y == self.height)
end

function Level:update()
    local unit = self:getActiveUnit()
    local timeSpent = unit:act()
    if timeSpent then
        self:registerUnit(unit, timeSpent)
        self:nextUnit()
        return true
    end
end

function Level:registerUnit(unit, deltaTime)
    local time = self.now + (deltaTime or 0)
    local units = self.units[time]
    if not units then
        units = {}
        self.units[time] = units
    end
    units[#units + 1] = unit
end

function Level:getActiveUnit()
    return self:getReadyUnits()[self.activeUnitIndex]
end

function Level:getReadyUnits()
    return self.units[self.now]
end

function Level:nextUnit()
    local readyUnits = self:getReadyUnits()
    if self.activeUnitIndex < #readyUnits then
        self.activeUnitIndex = self.activeUnitIndex + 1
    else
        self.units[self.now] = nil
        self.activeUnitIndex = 1
        repeat
            self.now = self.now + 1
        until self:getReadyUnits()
    end
end

return Level
