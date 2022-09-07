local Enemy = class({
    name = "enemy"
})

local data = {
    wolf = {
        health = {5, 8, 10},
        damage = {1, 2, 3},
    },
    snake = {
        health = {5, 8, 10},
        damage = {1, 2, 3},
    },
    boar = {
        health = {5, 8, 10},
        damage = {1, 2, 3},
    },
    spider = {
        health = {5, 8, 10},
        damage = {1, 2, 3},
    }
}

function Enemy:new(name, difficulty, opts)
    self.name = name
    self.health = data[name].health[difficulty]
    self.damage = data[name].damage[difficulty]

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
    Events.register(self, "damage_enemy")
end

function Enemy:damage_enemy(damage)
    Events.emit("display_damage", self.sprite, damage)
    self.health = self.health - damage

    if self.health <= 0 then
        self.sprite.color = {1, 0, 0}
        self.timer_death = timer(1,
            function(progress)
                self.sprite.alpha = 1 - progress
            end,
            function()
                Events.emit("end_battle")
                self.timer_death = nil
            end)
    end
end

function Enemy:enemy_start_attack()
    self.sprite.target_x = self.sprite.x - 128
    local triggered = false
    self.timer_attack = timer(1,
        function(progress)
            self.sprite.x = mathx.lerp(self.sprite.x, self.sprite.target_x, progress)
            if not triggered and progress >= 0.5 then
                triggered = true
            end
        end,
        function()
            Events.emit("damage_player", self.damage)
            self:enemy_end_attack()
        end)
end

function Enemy:enemy_end_attack()
    self.sprite.target_x = self.sprite.x + 128
    self.timer_attack = timer(1,
        function(progress)
            self.sprite.x = mathx.lerp(self.sprite.x, self.sprite.target_x, progress)
        end,
        function()
            self.timer_attack = nil
            Events.emit("finished_turn")
        end)
end

function Enemy:update(dt)
    if self.timer then self.timer:update(dt) end
    if self.timer_attack then self.timer_attack:update(dt) end
    if self.timer_death then self.timer_death:update(dt) end
end

function Enemy:draw()
    self.sprite:draw()
end

return Enemy
