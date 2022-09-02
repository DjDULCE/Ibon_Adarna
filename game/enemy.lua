local Enemy = class({
    name = "enemy"
})

function Enemy:new(name, opts)
    self.name = name
    self.sprite = Sprite(opts)

    self.target_x = WW * 0.7

    self.timer = timer(2,
        function(progress)
            self.sprite.x = mathx.lerp(self.sprite.x, self.target_x, progress)
        end,
        function()
            self.timer = nil
            Events.emit("start_battle", self)
        end)
end

function Enemy:update(dt)
    if self.timer then self.timer:update(dt) end
end

function Enemy:draw()
    self.sprite:draw()
end

return Enemy
