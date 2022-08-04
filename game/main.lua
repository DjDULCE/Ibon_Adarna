require("libs.batteries"):export()
io.stdout:setvbuf("no")

DEV = false
WW = 960
WH = 540
HALF_WW = WW * 0.5
HALF_WH = WH * 0.5

Anim8 = require("libs.anim8.anim8")
Assets= require("assets")
Button = require("button")
StateManager = require("state_manager")
UserData = require("user_data")

local Menu = require("menu")
local canvas

function iter_objects(tbl_orders, tbl_objects, fn, ...)
	for _, key in ipairs(tbl_orders) do
		local obj = tbl_objects[key]
		if obj and obj[fn] then
			obj[fn](obj, ...)
		end
	end
end

function love.load()
	UserData:init()
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

	if DEV then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.line(HALF_WW, 0, HALF_WW, WH)
		love.graphics.line(0, HALF_WH, WW, HALF_WH)
		love.graphics.setColor(1, 1, 1, 1)
	end
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
	if key == "`" then
		DEV = not DEV
		return
	end
    StateManager:keypressed(key)
end

function love.textinput(text)
    StateManager:textinput(text)
end

function love.mousefocus(focus)
    StateManager:mousefocus(focus)
end
