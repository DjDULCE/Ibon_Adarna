require("libs.batteries"):export()
io.stdout:setvbuf("no")

DEV = false
WW = 960
WH = 540
HALF_WW = WW * 0.5
HALF_WH = WH * 0.5

Anim8 = require("libs.anim8.anim8")
Reflowprint = require("libs.reflowprint")

Assets = require("assets")
Controls = require("controls")
Dialogue = require("dialogue")
Enemy = require("enemy")
Events = require("events")
Fade = require("fade")
Player = require("player")
Sprite = require("sprite")
StateManager = require("state_manager")
UserData = require("user_data")

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
	if DEV then
		local files = love.filesystem.getDirectoryItems("data/")
		for _, filename in ipairs(files) do
			if love.filesystem.getInfo("data/" .. filename).type == "file" then
				print(filename, require("data." .. filename:sub(0, -5)))
			end
		end

		local dif = {"easy", "medium", "hard"}
		for i = 1, 5 do
			for _, v in ipairs(dif) do
				local qf = love.filesystem.getDirectoryItems("data/game" .. i .. "/" .. v)
				for _, filename in ipairs(qf) do
					local str = string.format("data.game%d.%s.%s", i, v, filename:sub(0, -5))
					print("testing question files:", filename, require(str))
				end
			end
		end
	end

	FADE = Fade()
	UserData:init()
	Assets.init()


	local w, h = love.graphics.getDimensions()
	SCALE_X = w/WW
	SCALE_Y = h/WH

	canvas = love.graphics.newCanvas(WW, WH)

	StateManager.current = require("menu")()
	-- StateManager.current = require("scenario")(4)
	-- StateManager.current = require("scene")(5)
	-- StateManager.current = require("game")(1)
	StateManager:load()
end

-- function love.resize(w, h)
-- 	SCALE_X = w/WW
-- 	SCALE_Y = h/WH
-- end

function love.update(dt)
	FADE:update(dt)
	StateManager:update(dt)
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas(canvas)
		love.graphics.clear()
		love.graphics.push()
			StateManager:draw()
			FADE:draw()
		love.graphics.pop()
	love.graphics.setCanvas()

	love.graphics.draw(canvas, 0, 0, 0, SCALE_X, SCALE_Y)

	-- if DEV then
	-- 	love.graphics.setColor(1, 0, 0, 1)
	-- 	love.graphics.line(HALF_WW, 0, HALF_WW, WH)
	-- 	love.graphics.line(0, HALF_WH, WW, HALF_WH)
	-- 	love.graphics.setColor(1, 1, 1, 1)
	-- end
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
	StateManager:keypressed(key)
end

function love.textinput(text)
	StateManager:textinput(text)
end

function love.mousefocus(focus)
	StateManager:mousefocus(focus)
end
