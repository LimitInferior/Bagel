local Core = require "Core"

local Unit = Core.class()

function Unit:init(cell, name, image)
    self.cell = cell
    cell.unit = self
    self.name = name
    self.image = image
end

function Unit:getLevel()
    return self.cell.level
end

function Unit:getPosition()
    local cell = self.cell
    return cell.x, cell.y
end

function Unit:move(direction)
    return self:moveTo(self.cell:getAdjacent(direction))
end

function Unit:moveTo(newCell)
    if newCell and newCell:canPlaceUnit() then
        local oldCell = self.cell
        oldCell.unit = nil
        newCell.unit = self
        self.cell = newCell
        return true
    end
end

return Unit
