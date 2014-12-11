local Level = require "Level"
local Unit = require "Unit"
local keybindings = require "keybindings"

local graphics = love.graphics

local tileSize = 16
local atlases
local atlas
local tiles
local player
local saveName = "save.txt"

local function toScreen(x, y)
    return (x - 1) * tileSize, (y - 1) * tileSize
end

local function drawTile(name, x, y, flip)
    local dx = flip and 1 or 0
    local screenX, screenY = toScreen(x + dx, y)
    local scaleX = flip and -1 or 1
    graphics.draw(atlas, tiles[name], screenX, screenY, 0, scaleX, 1)
end

local function makeTileSet(tileNames, imageSize)
    local tiles = {}
    for i = 1, #tileNames do
        for j = 1, #tileNames[i] do
            local name = tileNames[i][j]
            local x, y = toScreen(j, i)
            tiles[name] = graphics.newQuad(x, y, tileSize, tileSize, imageSize, imageSize)
        end
    end
    return tiles
end

local function loadImage(name)
    local image = graphics.newImage(name)
    image:setFilter("nearest", "nearest")
    return image
end

local function save(x, file)
    local xType = type(x)
    if xType == "number" or xType == "boolean" then
        file:write(tostring(x))
    elseif xType == "string" then
        file:write(string.format("%q", x))
    elseif xType == "table" then
        file:write("{")
        for k, v in pairs(x) do
            file:write("[")
            save(k, file)
            file:write("]=")
            save(v, file)
            file:write(",")
        end
        file:write("}")
    else
        file:write("nil")
    end
end

local function saveGame()
    local level = player:getLevel()
    local data = 
    {
        width = level.width,
        height = level.height,
        wall = level.wall,
        floor = level.floor,
        units = {},
        features = {},
    }
    for x = 1, level.width do
        for y = 1, level.height do
            local cell = level:at(x, y)
            local unit = cell.unit
            if unit then
                table.insert(data.units, {x = x, y = y, name = unit.name, image = unit.image})
            end
            local feature = cell.feature
            if feature then
                table.insert(data.features, {x = x, y = y, feature = feature})
            end
        end
    end
    local saveFile = love.filesystem.newFile(saveName, "w")
    saveFile:write("return ")
    save(data, saveFile)
end

local function loadGame()
    if love.filesystem.exists(saveName) then
        local data = load(love.filesystem.newFile(saveName, "r"):read())()
        love.filesystem.remove(saveName)
        local level = Level.new(data.width, data.height, data.wall, data.floor)
        for i = 1, #data.features do
            local featureData = data.features[i]
            level:at(featureData.x, featureData.y).feature = featureData.feature
        end
        for i = 1, #data.units do
            local unitData = data.units[i]
            local unit = Unit.new(level:at(unitData.x, unitData.y), unitData.name, unitData.image)
            if i == 1 then -- TODO if unit.isPlayer
                player = unit
            end
        end
    else
        local level = Level.new(10, 10, {name = "wall", isWalkable = false}, {name = "floor", isWalkable = true})
        level:at(3, 4).feature = "closedDoor"
        player = Unit.new(level:at(2, 2), "Tanusha", "player")
    end
end

local directions =
{
    left = {x = -1, y = 0},
    right = {x = 1, y = 0},
    up = {x = 0, y = -1},
    down = {x = 0, y = 1},
}

local function moveUnit(unit, direction)
    unit:move(direction)
    if direction.x ~= 0 then
        unit.flip = direction.x > 0
    end
end

local commands =
{
    moveLeft = function(unit) moveUnit(unit, directions.left) end,
    moveRight = function(unit) moveUnit(unit, directions.right) end,
    moveUp = function(unit) moveUnit(unit, directions.up) end,
    moveDown = function(unit) moveUnit(unit, directions.down) end,
}

local keys = {}

function love.load()
    for command, key in pairs(keybindings) do
        keys[key] = commands[command]
    end
    atlases = {loadImage("atlas1.png"), loadImage("atlas2.png")}
    atlas = atlases[1]
    local terrainNames =
    {
        {"floor", "wall"},
        {"closedDoor", "openedDoor"}, 
        {"player"},
    }
    tiles = makeTileSet(terrainNames, atlas:getWidth())
    loadGame()
end

function love.draw()
    graphics.push()
    graphics.scale(2)
    local level = player:getLevel()
    for x = 1, level.width do
        for y = 1, level.height do
            local cell = level:at(x, y)
            drawTile(cell.terrain.name, x, y)
            local feature = cell.feature
            if feature then
                drawTile(feature, x, y)
            end
            local unit = cell.unit
            if unit then
                drawTile(unit.image, x, y, unit.flip)
            end 
        end
    end
    graphics.pop()
    graphics.print(love.timer.getFPS(), 0, 0)
end

local frameIndex = 1
local frameTimer = 0
function love.update(dt)
    frameTimer = frameTimer + dt
    if frameTimer > 0.4 then
        frameTimer = 0
        frameIndex = 3 - frameIndex -- 1 -> 2, 2 -> 1
        atlas = atlases[frameIndex]
    end
end

function love.keypressed(key)
    local command = keys[key]
    if command then
        command(player)
    end
end

function love.quit()
    saveGame()
end