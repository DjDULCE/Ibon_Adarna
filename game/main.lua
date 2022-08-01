require("libs.batteries"):export()
WW = 1920/2
WH = 1080/2

local StateManager = require("state_manager")
local Menu = require("menu")
local canvas

function love.load()
	canvas = love.graphics.newCanvas(WW, WH)

    StateManager.current = Menu()
    StateManager:load()
end

function love.update(dt)
    StateManager:update(dt)
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas(canvas)
		love.graphics.push()
			StateManager:draw()
		love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.draw(canvas)
end

function love.mousepressed(mx, my, mb)
    StateManager:mousepressed(mx, my, mb)
end

function love.mousereleased(mx, my, mb)
    StateManager:mousereleased(mx, my, mb)
end

function love.mousemoved(mx, my, dmx, dmy, istouch)
    StateManager:mousemoved(mx, my, dmx, dmy, istouch)
end

function love.keypressed(key)
    -- Dev:keypressed(key)
    StateManager:keypressed(key)
end

function love.textinput(text)
    StateManager:textinput(text)
end

function love.mousefocus(focus)
    StateManager:mousefocus(focus)
end
