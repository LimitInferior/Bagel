local Core = require "Core"
local MenuScene = require "MenuScene"

local SceneManager = Core.class()

function SceneManager:init(scene)
    self:push(scene)
end

function SceneManager:push(scene)
    scene.manager = self
    self.scene = scene
end

local sceneManager

function love.load()
    sceneManager = SceneManager.new(MenuScene.new())
end

function love.draw()
    sceneManager.scene:draw()
end

function love.update(dt)
    sceneManager.scene:update(dt)
end

function love.keypressed(key)
    sceneManager.scene:keypressed(key)
end

function love.quit()
    sceneManager.scene:quit()
end
