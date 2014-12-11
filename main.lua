local Level = require "Level"
local Unit = require "Unit"

local graphics = love.graphics

local tileSize = 16
local atlases
local atlas
local tiles
local player

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

function love.load()
    atlases = {loadImage("atlas1.png"), loadImage("atlas2.png")}
    atlas = atlases[1]
    local terrainNames =
    {
        {"floor", "wall"},
        {"player"},
    }
    tiles = makeTileSet(terrainNames, atlas:getWidth())
    local level = Level.new(10, 10, {name = "wall", isWalkable = false}, {name = "floor", isWalkable = true})
    player = Unit.new(level:at(2, 2), "Tanusha", "player")
end

function love.draw()
    graphics.push()
    graphics.scale(2)
    local level = player:getLevel()
    for x = 1, level.width do
        for y = 1, level.height do
            local cell = level:at(x, y)
            drawTile(cell.terrain.name, x, y)
        end
    end
    local x, y = player:getPosition()
    drawTile(player.image, x, y, player.flip)
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

local moveKeys =
{
    left = {x = -1, y = 0},
    right = {x = 1, y = 0},
    up = {x = 0, y = -1},
    down = {x = 0, y = 1},
}

function love.keypressed(key)
    local direction = moveKeys[key]
    if direction then
        player:move(direction)
        if direction.x ~= 0 then
            player.flip = direction.x > 0
        end
    end
end