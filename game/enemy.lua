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

    Events.register(self, "enemy_start_attack")
    Events.register(self, "enemy_end_attack")
end

function Enemy:enemy_start_attack()
    self.sprite.target_x = self.sprite.x - 128
    local triggered = false
    self.timer_attack = timer(1,
        function(progress)
            self.sprite.x = mathx.lerp(self.sprite.x, self.sprite.target_x, progress)
            if not triggered and progress >= 0.5 then
                Events.emit("on_hurt")
                triggered = true
            end
        end,
        function()
            self:enemy_end_attack()
        end)
end

function Enemy:enemy_end_attack()
    self.sprite.target_x = self.sprite.x + 128
    self.timer_attack = timer(1,
        function(progress)
            self.sprite.x = mathx.lerp(self.sprite.x, self.sprite.target_x, progress)
        end)
end

function Enemy:update(dt)
    if self.timer then self.timer:update(dt) end
    if self.timer_attack then self.timer_attack:update(dt) end
end

function Enemy:draw()
    self.sprite:draw()
end

return Enemy
