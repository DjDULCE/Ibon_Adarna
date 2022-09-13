local Enemy = class({
    name = "enemy"
})

local data = {
    wolf = {
        filipino = "lobo",
        health = { 10, 10, 10 },
        damage = { 1, 2, 4 },
    },
    snake = {
        filipino = "ahas",
        health = { 10, 10, 10 },
        damage = { 1, 2, 4 },
    },
    boar = {
        filipino = "baboy damo",
        health = { 10, 10, 10 },
        damage = { 1, 2, 4 },
    },
    spider = {
        filipino = "gagamba",
        health = { 10, 10, 10 },
        damage = { 1, 2, 4 },
    }
}

function Enemy:new(name, opts, images)
    local difficulty = UserData.data.difficulty
    self.name = name
    self.name_filipino = data[name].filipino
    self.health = data[name].health[difficulty]
    self.max_health = self.health
    self.damage = data[name].damage[difficulty]

    self.sprite = Sprite(opts)
    self.images = images

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
        self.sprite.color = { 1, 0, 0 }
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

    local gap = 8
    local scale = 0.25
    local iw = self.images.icon:getWidth()
    local font = Assets.fonts.impact20
    local ix = WW - iw * scale
    love.graphics.draw(self.images.icon, ix - iw * scale, gap, 0, scale, scale)

    local hw, hh = self.images.heart:getDimensions()
    local hscale = 0.15
    local bx = ix - gap * 2 - iw * scale - hw * hscale * 0.5
    local by = gap * 3 + hh * hscale * 0.5
    for i = 1, self.max_health do
        if i <= self.health then
            love.graphics.setColor(1, 0, 0, 1)
        else
            love.graphics.setColor(0, 0, 0, 1)
        end
        local x = bx - (i - 1) * hw * hscale - gap * (i - 1)
        love.graphics.draw(self.images.heart, x, by, 0, hscale, hscale, hw * 0.5, hh * 0.5)
    end
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(font)
    love.graphics.print(self.name_filipino,
        ix - gap * 2 - iw * scale,
        by + hh * scale * 0.5 + gap,
        0, 1, 1,
        font:getWidth(self.name_filipino), font:getHeight() * 0.5
    )
end

return Enemy
