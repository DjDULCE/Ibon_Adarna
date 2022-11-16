local Scenario = class({
    name = "scenario"
})

function Scenario:new(index)
    print("scenario", index)
    assert(index and type(index) == "number" and index > 0)
    if index > 5 then index = 5 end
    self.index = index
    local id = self:type()
    local idn = id .. tostring(index)

    self.video = Assets.load_video(idn)
    local vw, vh = self.video:getDimensions()
    self.vsx = WW/vw
    self.vsy = WH/vh
    self.alpha = 0
end

function Scenario:load()
    self.video:play()
    self.video_has_started = true
end

function Scenario:update(dt)
    if not (self.video_has_started and not self.video:isPlaying() and not self.fade_out) then
        return
    end
    self.fade_out = true
    print("scene video done for", self.index)
    Events.emit("fadeout", 3, function()
        self.alpha = 1
        Events.emit("fadein", 2, function()
            if self.index == 1 or self.index == 3 then
                local scene = require("scene")
                StateManager:switch(scene, self.index)
            elseif self.index == 4 then
                local game = require("game")
                StateManager:switch(game, self.index)
            elseif self.index == 5 then
                local menu = require("menu")
                StateManager:switch(menu, true)
            end
        end)
    end)
end

function Scenario:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.video, 0, 0, 0, self.vsx, self.vsy)
    love.graphics.setColor(0, 0, 0, self.alpha)
    local w, h = love.graphics.getDimensions()
    local dpi = love.graphics.getDPIScale()
    love.graphics.rectangle("fill", 0, 0, w * dpi, h * dpi)
    love.graphics.setColor(1, 1, 1, 1)
end

function Scenario:mousepressed(mx, my, mb)
end

function Scenario:exit()
    self.video:pause()
    self.video:getSource():pause()
end

return Scenario
