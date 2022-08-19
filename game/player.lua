local Player = class({
    name = "player"
})

function Player:new(x, y)
    self.x = x
    self.y = y

    self.width, self.height = 32, 32
    self.speed = 256
    self.gravity = 256

    Events.register(self, "on_down_left")
    Events.register(self, "on_down_right")
end

function Player:on_down_left()
    local dt = love.timer.getDelta()
    self.x = self.x - self.speed * dt
end

function Player:on_down_right()
    local dt = love.timer.getDelta()
    self.x = self.x + self.speed * dt
end

function Player:update(dt, ground_height)
    self.y = self.y + self.gravity * dt
    while (self.y + self.height) > (WH - ground_height) do
        self.y = self.y - dt
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1, 1)
end

return Player
