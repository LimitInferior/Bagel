local Core = require "Core"
local MainScene = require "MainScene"

local MenuScene = Core.class()

function MenuScene:init()
end

function MenuScene:draw()
    love.graphics.print("1 - New Game, 2 - Continue")
end

function MenuScene:update(dt)
end

function MenuScene:keypressed(key)
    if key == "1" then
        self.manager:push(MainScene.new(true))
    elseif key == "2" then
        self.manager:push(MainScene.new(false))
    end
end

function MenuScene:quit()
end

return MenuScene
