local graphics = love.graphics

local tileSize = 16
local atlases
local atlas
local tiles

local function toScreen(x, y)
    return (x - 1) * tileSize, (y - 1) * tileSize
end

local function drawTile(name, x, y)
    graphics.draw(atlas, tiles[name], toScreen(x, y))
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
end

function love.draw()
    graphics.push()
    graphics.scale(2)
    local size = 15
    for x = 1, size do
        for y = 1, size do
            local tileName = ((x == 1) or (x == size) or (y == 1) or (y == size)) and "wall" or "floor"
            drawTile(tileName, x, y)
        end
    end
    drawTile("player", 4, 5)
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
