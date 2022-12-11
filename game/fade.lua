local Fade = class({
    name = "Fade"
})

function Fade:new()
    self.alpha = 0

    Events.register(self, "fadeout")
    Events.register(self, "fadein")
end

function Fade:fadeout(duration, cb)
    self.timer = timer(duration,
        function(progress)
            self.alpha = progress
        end,
        function()
            print("finished fadeout")
            self.timer = nil
            if cb then
                cb()
            end
        end)
end

function Fade:fadein(duration, cb)
    self.timer = timer(duration,
        function(progress)
            self.alpha = 1 - progress
        end,
        function()
            print("finished fadein")
            self.timer = nil
            if cb then
                cb()
            end
        end)
end

function Fade:update(dt)
    if self.timer then self.timer:update(dt) end
end

function Fade:draw()
    love.graphics.setColor(0, 0, 0, self.alpha)
    local w, h = love.graphics.getDimensions()
    local dpi = love.graphics.getDPIScale()
    love.graphics.rectangle("fill", 0, 0, w * dpi, h * dpi)
    love.graphics.setColor(1, 1, 1, 1)
end

return Fade
