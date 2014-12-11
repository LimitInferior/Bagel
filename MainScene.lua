local Core = require "Core"
local Level = require "Level"
local Unit = require "Unit"
local Direction = require "Direction"
local keybindings = require "keybindings"

local graphics = love.graphics

local MainScene = Core.class()

function MainScene:init(newGame)
    self.saveName = "save.txt"
    self.tileSize = 16
    self.version = "0.0.2"    
    self.frameIndex = 1
    self.frameTimer = 0
    self:loadResources()
    if newGame then
        self:newGame()
    else
        self:loadGame()
    end
end

function MainScene:toScreen(x, y)
    return (x - 1) * self.tileSize, (y - 1) * self.tileSize
end

function MainScene:drawTile(name, x, y, flip)
    local dx = flip and 1 or 0
    local screenX, screenY = self:toScreen(x + dx, y)
    local scaleX = flip and -1 or 1
    graphics.draw(self.atlas, self.tiles[name], screenX, screenY, 0, scaleX, 1)
end

function MainScene:makeTileSet(tileNames, imageSize)
    local tiles = {}
    for i = 1, #tileNames do
        for j = 1, #tileNames[i] do
            local name = tileNames[i][j]
            local x, y = self:toScreen(j, i)
            tiles[name] = graphics.newQuad(x, y, self.tileSize, self.tileSize, imageSize, imageSize)
        end
    end
    return tiles
end

function MainScene:loadImage(name)
    local image = graphics.newImage(name)
    image:setFilter("nearest", "nearest")
    return image
end

function MainScene:save(x, file)
    local xType = type(x)
    if xType == "number" or xType == "boolean" then
        file:write(tostring(x))
    elseif xType == "string" then
        file:write(string.format("%q", x))
    elseif xType == "table" then
        file:write("{")
        for k, v in pairs(x) do
            file:write("[")
            self:save(k, file)
            file:write("]=")
            self:save(v, file)
            file:write(",")
        end
        file:write("}")
    else
        file:write("nil")
    end
end

function MainScene:saveGame()
    local level = self.player:getLevel()
    local data = 
    {
        version = self.version,
        width = level.width,
        height = level.height,
        wall = level.wall,
        floor = level.floor,
        now = level.now,
        units = {},
        features = {},
    }
    for x = 1, level.width do
        for y = 1, level.height do
            local cell = level:at(x, y)
            local feature = cell.feature
            if feature then
                table.insert(data.features, {x = x, y = y, feature = feature})
            end
        end
    end
    for time, units in pairs(level.units) do
        local unitsData = {}
        for i = 1, #units do
            local unit = units[i]
            local x, y = unit:getPosition()
            table.insert(unitsData, {x = x, y = y, name = unit.name, image = unit.image, isPlayer = unit.isPlayer})
        end
        data.units[time] = unitsData
    end
    local saveFile = love.filesystem.newFile(self.saveName, "w")
    saveFile:write("return ")
    self:save(data, saveFile)
end

function MainScene:newGame()
    local level = Level.new(10, 10, {name = "Wall", isWalkable = false}, {name = "Floor", isWalkable = true})
    level:at(3, 4).feature = "ClosedDoor"
    self.player = Unit.new(level:at(2, 2), "Tanusha", "Player", true)
    Unit.new(level:at(3, 6), "Dwarf", "Dwarf")
end

function MainScene:loadGame()
    if love.filesystem.exists(self.saveName) then
        local data = load(love.filesystem.newFile(self.saveName, "r"):read())()
        love.filesystem.remove(self.saveName)
        if data.version ~= self.version then
            self:newGame()
            return
        end
        local level = Level.new(data.width, data.height, data.wall, data.floor)
        for i = 1, #data.features do
            local featureData = data.features[i]
            level:at(featureData.x, featureData.y).feature = featureData.feature
        end
        for time, units in pairs(data.units) do
            for i = 1, #units do
                local unitData = units[i]
                local unit = Unit.new(level:at(unitData.x, unitData.y), unitData.name, unitData.image, unitData.isPlayer, time)
                if unit.isPlayer then -- TODO if unit.isPlayer
                    self.player = unit
                end
            end
        end
        level.now = data.now
    else
        self:newGame()
    end
end

local function moveUnit(unit, direction)
    local timeSpent = unit:move(direction)
    if direction.x ~= 0 then
        unit.flip = direction.x > 0
    end
    return timeSpent
end

local commands =
{
    moveLeft = function(unit) return moveUnit(unit, Direction.left) end,
    moveRight = function(unit) return moveUnit(unit, Direction.right) end,
    moveUp = function(unit) return moveUnit(unit, Direction.up) end,
    moveDown = function(unit) return moveUnit(unit, Direction.down) end,
}


function MainScene:loadResources()
    self.keys = {}
    for command, key in pairs(keybindings) do
        self.keys[key] = commands[command]
    end
    self.atlases = {self:loadImage("atlas1.png"), self:loadImage("atlas2.png")}
    self.atlas = self.atlases[1]
    local terrainNames =
    {
        {"Floor", "Wall"},
        {"ClosedDoor", "OpenedDoor"}, 
        {"Player", "Dwarf"},
    }
    self.tiles = self:makeTileSet(terrainNames, self.atlas:getWidth())
    love.window.setTitle("Bagel " .. self.version)
end

function MainScene:draw()
    graphics.push()
    graphics.scale(2)
    local level = self.player:getLevel()
    for x = 1, level.width do
        for y = 1, level.height do
            local cell = level:at(x, y)
            self:drawTile(cell.terrain.name, x, y)
            local feature = cell.feature
            if feature then
                self:drawTile(feature, x, y)
            end
            local unit = cell.unit
            if unit then
                self:drawTile(unit.image, x, y, unit.flip)
            end 
        end
    end
    graphics.pop()
    graphics.print(love.timer.getFPS(), 0, 0)
end

function MainScene:update(dt)
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer > 0.4 then
        self.frameTimer = 0
        self.frameIndex = 3 - self.frameIndex -- 1 -> 2, 2 -> 1
        self.atlas = self.atlases[self.frameIndex]
    end
end

function MainScene:keypressed(key)
    local command = self.keys[key]
    if command then
        self.player.command = command
        while self.player:getLevel():update() do
        end
    end
end

function MainScene:quit()
    self:saveGame()
end

return MainScene
