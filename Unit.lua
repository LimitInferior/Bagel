local Core = require "Core"
local Direction = require "Direction"

local Unit = Core.class()

function Unit:init(cell, name, image, isPlayer, time)
    self.cell = cell
    cell.unit = self
    self.name = name
    self.image = image
    self.isPlayer = isPlayer
    self:getLevel():registerUnit(self, time)
end

function Unit:getLevel()
    return self.cell.level
end

function Unit:getPosition()
    local cell = self.cell
    return cell.x, cell.y
end

function Unit:getMoveSpeed()
    return 1
end

function Unit:act()
    if self.isPlayer then
        local command = self.command
        if command then
            self.command = nil
            return command(self)
        end
    else
        self:move(Direction.random())
        return self:getMoveSpeed()
    end
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
            return self:getMoveSpeed()
        elseif newCell.feature == "ClosedDoor" then
            newCell.feature = "OpenedDoor"
            return self:getMoveSpeed()
        end
    end
end

return Unit
