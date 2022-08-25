local Player = class({
    name = "player"
})

function Player:new(x, y)
    self.images = Assets.load_images("player")
    self.x = x
    self.y = y
    self.dir = 1

    self.width, self.height = 49, 53
    self.speed = 256
    self.gravity = 256

    local walk_width, walk_height = self.images.walk:getDimensions()
    local grid_walk = Anim8.newGrid(self.width, self.height, walk_width, walk_height)
    self.anim_walk = Anim8.newAnimation(grid_walk("1-9", 1), 0.1)

    self.anim = self.anim_walk

    self.ox = self.width * 0.5

    Events.register(self, "on_down_left")
    Events.register(self, "on_down_right")
    Events.register(self, "on_clicked_a")
    Events.register(self, "on_clicked_b")
end

function Player:on_down_left()
    local dt = love.timer.getDelta()
    self.x = self.x - self.speed * dt
    self.dir = 1
    self.anim:update(dt)
end

function Player:on_down_right()
    local dt = love.timer.getDelta()
    self.x = self.x + self.speed * dt
    self.dir = -1
    self.anim:update(dt)
end

function Player:on_clicked_a()
    error()
end

function Player:on_clicked_b()
    error()
end

function Player:update(dt, ground_height)
    self.y = self.y + self.gravity * dt
    while (self.y + self.height) > (WH - ground_height) do
        self.y = self.y - dt
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.anim:draw(self.images.walk, self.x, self.y, 0, self.dir, 1, self.ox, 0)
    love.graphics.setColor(1, 1, 1, 1)
end

return Player
