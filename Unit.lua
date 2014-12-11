local Core = require "Core"

local Unit = Core.class()

function Unit:init(cell, name, image, isPlayer)
    self.cell = cell
    cell.unit = self
    self.name = name
    self.image = image
    self.isPlayer = isPlayer
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
    if newCell then
        if newCell:canPlaceUnit() then
            local oldCell = self.cell
            oldCell.unit = nil
            newCell.unit = self
            self.cell = newCell
            return true
        elseif newCell.feature == "ClosedDoor" then
            newCell.feature = "OpenedDoor"
            return true
        end
    end
end

return Unit
